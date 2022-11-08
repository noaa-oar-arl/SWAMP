"""
Compute max moisture from CRN data during 2010--20
"""
from pathlib import Path

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import xarray as xr
from scipy import interpolate

from dl import get_crn

HERE = Path(__file__).parent
ORIG = HERE / "orig"

days = pd.date_range("2010/01/01", "2020/12/31")

# # NOTE: takes several minutes if the files are not cached
# df = get_crn(days)

# d = [50, 100, 200, 500, 1000]  # depth (mm)
# sm_cols = [
#     'SOIL_MOISTURE_5_DAILY',
#     'SOIL_MOISTURE_10_DAILY',
#     'SOIL_MOISTURE_20_DAILY',
#     'SOIL_MOISTURE_50_DAILY',
#     'SOIL_MOISTURE_100_DAILY',
# ]

#
# Get maxmoist from original SWAMP (following PROCESS_DAILY/Soil_moisture_model_grid_fine_rel.ncl)
#

# The minmax files don't have site ID column, but soil properties has it
# NOTE: this file has 42 all-(-999) rows and 13 all-0 rows
nsite = 107  # NOTE: not all of the CRN sites
data = np.loadtxt(ORIG / "MAIN_CRN/soil_properties.txt")
assert data.shape[0] == nsite
site_id = data[:, 0].astype(int)
assert len(set(site_id)) == nsite, "should be unique"

# Aggregate the minmax file data
dmin_lb = 0
dmax_ub = 1000  # 1000 mm (100 cm)
dmin = np.full(nsite, dmax_ub)
dmax = np.full(nsite, dmin_lb)
for fp in sorted((ORIG / "PROCESS_DAILY").glob("minmax_????.txt")):
    data = np.loadtxt(fp)
    dmin_y = data[:, 0]
    dmax_y = data[:, 1]
    dmin = np.minimum(dmin, dmin_y)
    dmax = np.maximum(dmax, dmax_y)
dmin[dmin == dmax_ub] = np.nan  # 0
dmax[dmax == dmin_lb] = np.nan  # 1000
# ^ Such setting to NaN is done for "waterdrun"

# Get site lat/lon from another file
df_lat_lon = pd.read_csv(
    ORIG / "MAIN_CRN/stationID_lat_lon.txt", names=["site_id", "lat", "lon"], delim_whitespace=True
)
df_lat_lon["site_id"] = df_lat_lon.site_id.astype(int)
# NOTE: a few sites are missing from this file
lat = np.full(nsite, np.nan)
lon = np.full(nsite, np.nan)
for i, id_ in enumerate(site_id):
    try:
        row = df_lat_lon.set_index("site_id").loc[id_]
    except KeyError:
        print(f"site {id_} not in the lat/lon file")
    else:
        lat[i] = row.lat
        lon[i] = row.lon

# Make minmax df
df_orig = pd.DataFrame({"site_id": site_id, "lat": lat, "lon": lon, "dmin": dmin, "dmax": dmax})

# To grid??
df_ = df_orig.dropna(subset=["lat", "lon", "dmax"])
points = (df_.lon, df_.lat)
values = df_.dmax
grid_x, grid_y = np.mgrid[-125:-65:300j, 25:50:200j]
out = interpolate.griddata(points, values, (grid_x, grid_y), method="nearest")
# NOTE: linear and nearest look the best
# NOTE: really should transform from lat/lon from x/y for the interp

# Plot
proj = ccrs.Mercator()
tran = ccrs.PlateCarree()
fig, ax = plt.subplots(subplot_kw=dict(projection=proj), constrained_layout=True, figsize=(7, 4))
ax.set_extent([-125, -70, 25, 50])
ax.coastlines(linewidth=1.5, color="0.5")
ax.gridlines(draw_labels=True)
im = ax.scatter(
    df_orig.lon, df_orig.lat, s=80, c=df_orig.dmax, transform=tran, zorder=10, ec="0.5", lw=0.5
)
cb = fig.colorbar(im, label="dmax [mm]")

ax.pcolormesh(grid_x, grid_y, out, transform=tran, norm=cb.norm, alpha=0.85)

# TODO: also plot dmin and delta

# Compute from CRN data?
dates = pd.date_range("2010/01/01", "2021/01/01", freq="D")[:-1]
df = get_crn(dates)
sm_cols = df.columns[df.columns.str.startswith("SOIL_MOISTURE_")].tolist()
meta_cols = ["WBANNO", "LST_DATE", "LATITUDE", "LONGITUDE"]
df_sm = (
    df[meta_cols + sm_cols]
    .rename(columns=lambda x: "sm_" + x.split("_")[2] if x.startswith("SOIL_MOISTURE_") else x)
    .rename(columns={"WBANNO": "siteid", "LST_DATE": "time", "LATITUDE": "lat", "LONGITUDE": "lon"})
)
assert (df_sm.time == df_sm.time.dt.floor("D")).all()

# TODO: xarray interp later could be another option
df_sm["sm_25"] = (df_sm.sm_50 - df_sm.sm_20) / (50 - 20) * (25 - 20)

# Form xarray Dataset
# sm_cols = df_sm.columns[df_sm.columns.str.startswith("sm_")].sort_values(key=lambda x: x.str.slice(3, None).astype(float))
sm_cols = sorted(
    df_sm.columns[df_sm.columns.str.startswith("sm_")], key=lambda x: int(x.split("_")[1])
)
sm_d_vals = [float(x.split("_")[1]) for x in sm_cols]
# df_sm["sm"] = df_sm[sm_cols].values.tolist()
# TODO: un-widen the table (variable column, value column)

ds_sm = (
    df_sm.set_index(["siteid", "time"])
    # .drop(columns=sm_cols)
    .to_xarray()
    .assign(depth=("depth", sm_d_vals))
    .set_coords(["lat", "lon"])
)

ds_sm["sm"] = (
    ("siteid", "time", "depth"),
    np.empty((ds_sm.sizes["siteid"], ds_sm.sizes["time"], len(sm_d_vals))),
    {
        "long_name": "Soil moisture",
        "units": "m3 m-3",
    },
)
for d, vn in zip(sm_d_vals, sm_cols):
    ds_sm["sm"].loc[dict(depth=d)] = ds_sm[vn]

ds_sm = ds_sm.drop_vars(sm_cols)

# 25-cm sm: trapezoidal integrated average over the 0--25-cm region
avg = ds_sm.sm.sel(depth=slice(None, 25)).integrate("depth") / 25

gb = avg.groupby("time.year")
res = xr.merge([gb.min().rename("min"), gb.mean().rename("mean"), gb.max().rename("max")])
df_res = (
    res.to_dataframe()
    .reset_index()
    .merge(df_sm.groupby("siteid")[["lat", "lon"]].first().reset_index(), how="left", on="siteid")
)
# TODO: ensure lat/lon unique for site in time

plt.show()

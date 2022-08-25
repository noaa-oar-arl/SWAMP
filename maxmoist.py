"""
Compute max moisture from CRN data during 2010--20
"""
from pathlib import Path

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# from dl import get_crn

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

# Plot
proj = ccrs.Mercator()
tran = ccrs.PlateCarree()
fig, ax = plt.subplots(subplot_kw=dict(projection=proj), constrained_layout=True)
ax.set_extent([-125, -70, 25, 50])
ax.coastlines(linewidth=1.5, color="0.5", zorder=0)
ax.gridlines(draw_labels=True)
im = ax.scatter(df_orig.lon, df_orig.lat, s=60, c=df_orig.dmax, transform=tran)
cb = fig.colorbar(im, label="dmax [mm]")

plt.show()

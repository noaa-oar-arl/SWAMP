"""
SWAMP
"""
import warnings
from pathlib import Path

import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import xarray as xr
from metpy.interpolate import interpolate_to_grid, remove_nan_observations

from dl import get_alexi, get_crn, get_prism

plt.close("all")

warnings.filterwarnings("ignore", message=r"note 'stable' PRISM file for [0-9]{8} not found")

HERE = Path(__file__).parent
ORIG = HERE / "orig"

# Define output grid
# NOTE: this is 3.8-km in lat and ~ 4.4-km in lon
nlat, nlon = (720, 1150)
lat = np.linspace(25, 50, nlat)
lon = np.linspace(-125, -65, nlon)
grid = xr.Dataset(
    coords={
        "lat": (("lat",), lat),
        "lon": (("lon",), lon),
    }
)

# For now, use the coeffs that already exist
# NOTE: slp is the one that gets used in the current original SWAMP
# NOTE: this array has 39% 0 values and 17% -21.52 values, the rest positive but < 1
# NOTE: some of the -21.52 values are over land (TX ~ 27 and below, FL ~ 26 and below), makes results weird
slp_coeffs = np.loadtxt(ORIG / "PROCESS_DAILY/slp_weights.txt")
int_coeffs = np.loadtxt(ORIG / "PROCESS_DAILY/int_weights.txt")
assert slp_coeffs.shape == int_coeffs.shape == (nlat, nlon)
c = slp_coeffs

# NOTE: 215 (08/03) is missing, as are other random days
start = "2022/04/01"
end = "2022/04/15"
ic = None

# IC based on CRN
# TODO: try using the AWC calculation instead
df = get_crn([start])
x = df["LONGITUDE"]
y = df["LATITUDE"]
v = df["SOIL_MOISTURE_5_DAILY"].copy()
v.loc[v == -99] = np.nan
x, y, v = remove_nan_observations(x, y, v)
xg, yg, vg = interpolate_to_grid(x, y, v, interp_type="rbf", hres=0.1)
ic = xr.DataArray(data=vg, coords={"lat": yg[:, 0], "lon": xg[0, :]}, dims=("lat", "lon")).interp(
    lat=grid.lat, lon=grid.lon
)

days = pd.date_range(start, end, freq="D")
ntime = len(days)

# Compute P - ET at the grid
print("loading PRISM P")
p = get_prism(days).ppt
print("loading ALEXI ET")
et = get_alexi(days).et
print("computing P - ET")
p_minus_et = p.interp(lat=grid.lat, lon=grid.lon) - 0.408 * et.interp(lat=grid.lat, lon=grid.lon)
p_minus_et.attrs.update(long_name="P - ET", units="mm")

# Initialize sm dataset
print("computing SM")
soil_depth_cm = 25  # soil depth of interest
soil_depth_mm = soil_depth_cm * 10
ds = grid.copy()
ds["c"] = (("lat", "lon"), c, {"long_name": "Coefficient"})
ds["c"] = ds.c.where(ds.c > 0, np.nan)
ds["sm"] = (
    ("time", "lat", "lon"),
    np.empty((ntime, nlat, nlon)),
    {
        "long_name": "Soil moisture",
        "units": "m3 m-3",
        "description": f"Volumetric soil water content for the top {soil_depth_cm} cm of soil",
    },
)
ds["time"] = days

if ic is None:
    # Default IC: 0 but using the land mask from P - ET or c
    # TODO: maybe better to use regionmask since inland NaN areas seem to change
    # x = p_minus_et.isel(time=0)
    x = ds.c
    ic = x.where(x.isnull(), 0)

ds["sm"].loc[dict(time=days[0])] = ic

for i in range(1, len(days)):
    delta_mm = ds.c * p_minus_et.isel(time=i)
    # delta_mm = p_minus_et.isel(time=i)  # for "smn" in the Fortran (no weighting coeffs used)

    # Multiplying by the soil depth, we convert the previous sm field from m3 m-3 to mm
    # This gives it units like: mm water per <soil depth> depth of soil per unit area
    ds["sm"].loc[dict(time=days[i])] = np.clip(
        (soil_depth_mm * ds.sm.isel(time=i - 1) + delta_mm) / soil_depth_mm,
        0,
        1,
    )


# -21.25 coeffs
proj = ccrs.Mercator()
tran = ccrs.PlateCarree()
fig, ax = plt.subplots(subplot_kw=dict(projection=proj))
ax.coastlines(linewidth=3, color="orangered")
ax.gridlines(draw_labels=True)
ax.pcolormesh(lon, lat, np.where(slp_coeffs == -21.52, 1, np.nan), transform=tran)

# Plot coeffs
print("plotting")
ds.c.plot(vmin=0, size=4, aspect=1.6)
plt.tight_layout()

# Plot P - ET
p_minus_et.plot(col="time", col_wrap=5, robust=True, size=2, aspect=1.5)

# Plot results
ds.sm.plot(col="time", col_wrap=5, robust=True, size=2, aspect=1.5)

plt.show()

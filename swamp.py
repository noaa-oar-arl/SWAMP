"""
SWAMP
"""
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import xarray as xr

from dl import get_alexi, get_prism

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
slp_coeffs = np.loadtxt(ORIG / "PROCESS_DAILY/slp_weights.txt")
int_coeffs = np.loadtxt(ORIG / "PROCESS_DAILY/int_weights.txt")
assert slp_coeffs.shape == int_coeffs.shape == (nlat, nlon)
c = slp_coeffs

# NOTE: 215 (08/03) is missing
start = "2022/05/01"
end = "2022/05/20"
ic = None

days = pd.date_range(start, end, freq="D")
ntime = len(days)

# Compute P - ET at the grid
p = get_prism(days).ppt
et = get_alexi(days).et
p_minus_et = p.interp(lat=grid.lat, lon=grid.lon) - et.interp(lat=grid.lat, lon=grid.lon)
# NOTE: original SWAMP multiples ET by 0.408, but they already have matching units...??

# Initialize sm dataset
ds = grid.copy()
ds["c"] = (("lat", "lon"), c)
ds["sm"] = (("time", "lat", "lon"), np.zeros((ntime, nlat, nlon)), {"long_name": "Soil moisture"})
ds["time"] = days

# ic = ds.sm.isel(time=0) + 1  # testing
if ic is not None:
    ds["sm"].loc[dict(time=days[0])] = ic

for i in range(1, len(days)):
    # delta = c * p_minus_et.isel(time=i)
    delta = ds.c * p_minus_et.isel(time=i)
    ds["sm"].loc[dict(time=days[i])] = np.clip(ds.sm.isel(time=i - 1) + delta / 1000, 0, 1)


ds.sm.plot(col="time", col_wrap=4, vmax=0.1)

plt.show()

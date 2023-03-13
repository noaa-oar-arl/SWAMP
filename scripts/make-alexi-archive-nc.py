"""
Make netCDF of the ALEXI archive data.

Original directories are ~ 1.3 GB per year.
These nc files are ~ 400 MB per year and easier to load/use.

Currently missing:
- 2012-12-31
- 2016-12-31
- 2020-12-31
- (and multiple random days in current year)

👆 These are all leap years.
#TODO: Maybe actually leap day is skipped and should switch to leap-less calendar.
"""
import calendar
import datetime
import os
import subprocess
from pathlib import Path

import pandas as pd
import xarray as xr

from swamp import load_alexi

now = datetime.datetime.now()
here = Path(__file__).parent
src_dir = Path("/groups/ESS3/pcampbe8/ALEXI/")  # on Hopper
dst_dir = here / "../alexi"

missing_combined = []
for y_dir in sorted(src_dir.glob("????")):
    y = int(y_dir.name)
    print(y)

    if y == now.year:
        print(f"skipping {y}")

    ds = xr.concat([load_alexi(p) for p in sorted(y_dir.glob("*.dat"))], dim="time")

    # Check times
    nday = 366 if calendar.isleap(y) else 365
    dates = pd.date_range(f"{y}/01/01", f"{y}/12/31")
    assert len(dates) == nday
    assert (ds.time.dt.year == y).all()
    if ds.sizes["time"] != nday:
        missing = set(dates) - set(pd.to_datetime(ds.time))
        s_missing = sorted(t.strftime(r"%Y-%m-%d") for t in missing)
        print(f"warning: {y} is missing dates {s_missing}")
        missing_combined.extend(s_missing)

    ds.to_netcdf("tmp.nc")

    dst = (dst_dir / f"{y}.nc").as_posix()
    cmd = ["ncks", "-O", "-7", "-L", "5", "--baa=4", "--ppc", "default=5", "tmp.nc", dst]
    print(" ".join(cmd))
    subprocess.run(cmd, check=True)

if missing_combined:
    print("Currently missing:")
    print("\n".join(f"- {s}" for s in missing_combined))

os.remove("tmp.nc")

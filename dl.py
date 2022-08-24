"""
Download the SWAMP inputs.
"""
from __future__ import annotations

import re
import warnings
from pathlib import Path

import numpy as np
import pandas as pd
import requests
import xarray as xr

CACHE_DIR = Path(__file__).parent / "cache"

assert CACHE_DIR.is_dir()


def get_crn(days, *, use_cache=True):
    """Get daily soil (and vegetation?) CRN data for `days`.

    Info: https://www.ncei.noaa.gov/access/crn/qcdatasets.html

    Data: https://www.ncei.noaa.gov/pub/data/uscrn/products/daily01/
    """
    days = pd.DatetimeIndex(days)

    # Get metadata
    # "This file contains the following three lines: Field Number, Field Name and Unit of Measure."
    base_url = "https://www.ncei.noaa.gov/pub/data/uscrn/products/daily01"
    r = requests.get(
        f"{base_url}/headers.txt",
    )
    r.raise_for_status()
    lines = r.text.splitlines()
    assert len(lines) == 3
    nums = lines[0].split()
    columns = lines[1].split()
    assert len(nums) == len(columns)
    assert nums == [str(i+1) for i in range(len(columns))]

    # Get available years from the main page
    # e.g. `>2000/<`
    r = requests.get(f"{base_url}/")
    r.raise_for_status()
    available_years: list[str] = re.findall(r">([0-9]{4})/?<", r.text)

    # Get files
    # TODO: parallelize using Dask or joblib
    dfs_per_year = []
    years = days.year.astype(str).unique()
    for year in years:
        if year not in available_years:
            raise ValueError(f"year {year} not in detected available years {available_years}")

        cached_fp = CACHE_DIR / f"crn_{year}.csv.gz"
        is_cached = cached_fp.is_file()

        if not is_cached or not use_cache:
            # Get filenames from the year page
            # e.g. `>CRND0103-2020-TX_Palestine_6_WNW.txt<`
            url = f"{base_url}/{year}/"
            r = requests.get(url)
            r.raise_for_status()
            fns = re.findall(r">(CRN[a-zA-Z0-9\-_]*\.txt)<", r.text)
            if not fns:
                warnings.warn(f"no files found for year {year} (url {url})")
            
            dfs_per_file = []
            for fn in fns:
                url = f"{base_url}/{year}/{fn}"
                print(url)
                df = pd.read_csv(
                    url,
                    delim_whitespace=True,
                    names=columns,
                    parse_dates=["LST_DATE"],
                    infer_datetime_format=True,
                    na_values=[-99999, -9999.0],
                )
                dfs_per_file.append(df)
            df = pd.concat(dfs_per_file)
        else:
            # Read from cache
            df = pd.read_csv(cached_fp, index_col=0, parse_dates=["LST_DATE"])

        if not is_cached:
            df.to_csv(cached_fp)  # ~ 2 MB

        dfs_per_year.append(df)

    # Combined df
    site_cols = [
        'WBANNO',
        'LST_DATE',
        'CRX_VN',
        'LONGITUDE',
        'LATITUDE',
    ]
    assert set(site_cols) < set(df)
    data_cols = [c for c in df.columns if c not in site_cols]
    df = (
        pd.concat(dfs_per_year)
        .dropna(subset=data_cols, how="all")
        .reset_index(drop=True)
    )
    if df.empty:
        warnings.warn("dataframe empty after dropping missing data rows")

    # Select data at days
    df = df[df.LST_DATE.isin(days.floor("D"))].reset_index(drop=True)

    return df


def get_prism(days, *, use_cache=True):
    """Get PRISM precip data.
    
    Info: https://prism.oregonstate.edu/

    Data: https://ftp.prism.oregonstate.edu/daily/ppt/
    """
    import zipfile

    days = pd.DatetimeIndex(days)

    base_url = "https://ftp.prism.oregonstate.edu/daily/ppt"

    # Get available years from the main page
    # e.g. `>2000/<`
    r = requests.get(f"{base_url}/")
    r.raise_for_status()
    available_years: list[str] = re.findall(r">([0-9]{4})/?<", r.text)

    dss_per_day = []
    fns_year = {}
    ymds = days.strftime(r"%Y%m%d").unique()
    # TODO: cache the files (probably just the straight zip ones? or nc?)
    for ymd in ymds:
        year = ymd[:4]
        if year not in available_years:
            raise ValueError(f"year {year} not in detected available years {available_years}")

        available_fns = fns_year.get(year, None)
        if available_fns is None:
            # Get filenames from the year page
            # e.g. `>PRISM_ppt_stable_4kmD2_20200121_bil.zip<`
            url = f"{base_url}/{year}/"
            r = requests.get(url)
            r.raise_for_status()
            available_fns = re.findall(r">(PRISM_ppt_[a-zA-Z0-9_]*_bil\.zip)<", r.text)
            if not available_fns:
                warnings.warn(f"no files found for year {year} (url {url})")
            fns_year[year] = available_fns

        # Download zip archive (~ 1--2 MB)
        # https://prism.oregonstate.edu/documents/PRISM_downloads_FTP.pdf
        # e.g. `https://ftp.prism.oregonstate.edu/daily/ppt/1996/PRISM_ppt_stable_4kmD2_19960101_bil.zip`

        # "For monthly and daily data, the “stability” portion of the filename will change over time.
        #  Datasets from 6-12 months ago are considered “provisional” because they are
        #  still likely to change; you will probably want to re-download the files
        #  once their names say “stable” (i.e., after 12 months have elapsed)."
        stabilities = ["stable", "provisional", "early"]

        # Look for stable first, etc.
        for stab in stabilities:
            fn = f"PRISM_ppt_{stab}_4kmD2_{ymd}_bil.zip"
            if fn in available_fns:
                break
        else:
            raise ValueError(f"file for {ymd} not found. Check {base_url}/{year}/")
        if stab in stabilities[1:]:
            warnings.warn(f"note 'stable' file for {ymd} not found, using {stab!r}")

        zip_fp = CACHE_DIR / fn
        is_cached = zip_fp.is_file()
        if not is_cached or not use_cache:
            # Download file
            url = f"{base_url}/{year}/{fn}"
            print(url)
            r = requests.get(url)
            r.raise_for_status()
            with open(zip_fp, "wb") as f:
                f.write(r.content)

        # Get the BIL from the zip
        with zipfile.ZipFile(zip_fp, 'r') as zf:
            bil_fn = str(Path(fn).with_suffix(".bil"))
            try:
                data = zf.read(bil_fn)  # bytes
            except KeyError:
                print(f"{bil_fn!r} not found in archive. Archive namelist: {zf.namelist()}")
                raise

            # BIL metadata (text file)
            # hdr_fn = str(Path(fn).with_suffix(".hdr"))

        # Read the BIL into an array
        # https://pymorton.wordpress.com/2016/02/26/plotting-prism-bil-arrays-without-using-gdal/
        # TODO: the metadata we use here is in the HDR text file, could get from there
        prism_ncols = 1405
        prism_nrows = 621
        prism_nodata = -9999
        prism_ulxmap = -125.000000000000
        prism_ulymap =   49.916666666667
        prism_xdim   =    0.041666666667  # 2.5 arc minutes, ~ 4 km
        prism_ydim   =    0.041666666667
        prism_array = np.frombuffer(data, dtype=np.float32)  # note: `np.fromfile()` didn't work
        prism_array = prism_array.reshape(prism_nrows, prism_ncols)

        # Construct Dataset
        arr = np.where(prism_array == prism_nodata, np.nan, prism_array)  # note: couldn't modify buffer in place
        lon = prism_ulxmap + np.arange(prism_ncols) * prism_xdim
        lat = prism_ulymap - np.arange(prism_nrows) * prism_ydim
        ds = xr.Dataset(
            data_vars={
                "ppt": (("lat", "lon"), arr, {
                    "long_name": "Precipitation",
                    "units": "mm",
                    "description": "Daily total precipitation (rain + melted snow)",
                }),
                "ppt_stability": ((), stab, {
                    "long_name": "Stability",
                    "description": "'stable', 'provisional', or 'early', mostly depending on when the data was released",
                }),
            },
            coords={
                "lat": (("lat",), lat),
                "lon": (("lon",), lon),
            }
        )
        dss_per_day.append(ds)

    # Combined Dataset
    ds = xr.concat(dss_per_day, dim="time")
    ds["time"] = (("time",), pd.to_datetime(ymds))

    return ds


def get_alexi(days, *, use_cache=True):
    """Get ALEXI data.
    
    Only available for current year!

    Data: https://geo.nsstc.nasa.gov/SPoRT/outgoing/crh/4ecostress/
    """
    days = pd.DatetimeIndex(days)

    base_url = "https://geo.nsstc.nasa.gov/SPoRT/outgoing/crh/4ecostress"

    yjs = days.strftime(r"%Y%j").unique()

    # Get available yjs from the main page
    # e.g. `>2022001<`
    url = f"{base_url}/"
    r = requests.get(url)
    r.raise_for_status()
    available_yjs = re.findall(r">([0-9]{7})<", r.text)
    if not available_yjs:
        warnings.warn(f"search of {base_url}/ detected no available dates")

    dss_per_yj = []
    for yj in yjs:
        if yj not in available_yjs:
            raise ValueError(f"date {yj} not in detected available dates {available_yjs}")

        # e.g. https://geo.nsstc.nasa.gov/SPoRT/outgoing/crh/4ecostress/2022019/ALEXI_ET_4KM_CONUS_V01_2022019.dat
        fn = f"ALEXI_ET_4KM_CONUS_V01_{yj}.dat"
        fp = CACHE_DIR / fn

        is_cached = fp.is_file()
        if not is_cached or not use_cache:
            # Download file
            url = f"{base_url}/{yj}/{fn}"
            print(url)
            r = requests.get(url)
            r.raise_for_status()
            # NOTE: sometimes dir for current day doesn't have the ET file yet
            with open(fp, "wb") as f:
                f.write(r.content)

        alexi_nlat = 625  # TODO: confirm the grid stuff!?
        alexi_nlon = 1456
        alexi_lllat = 24.80
        alexi_lllon = -125.0
        alexi_dlat = 0.04
        alexi_dlon = 0.04
        alexi_bad = -9999.
        arr = np.fromfile(fp, dtype=np.float32)
        arr = arr.reshape(alexi_nlat, alexi_nlon)
        arr[arr == alexi_bad] = np.nan

        # Construct Dataset
        lat = alexi_lllat + np.arange(alexi_nlat) * alexi_dlat
        lon = alexi_lllon + np.arange(alexi_nlon) * alexi_dlon
        ds = xr.Dataset(
            data_vars={
                "et": (("lat", "lon"), arr, {
                    "long_name": "Evapotranspiration",
                    "units": "mm",
                    "description": "Daily evapotranspiration",
                }),
            },
            coords={
                "lat": (("lat",), lat),
                "lon": (("lon",), lon),
            }
        )
        dss_per_yj.append(ds)

    # Combined Dataset
    ds = xr.concat(dss_per_yj, dim="time")
    ds["time"] = (("time",), pd.to_datetime(yjs, format=r"%Y%j"))

    return ds


if __name__ == "__main__":
    days = pd.date_range("2022/08/01", periods=2, freq="D")
    print(days)

    # df = get_crn(days)

    # ds = get_prism(days)

    ds = get_alexi(days)

    import cartopy.crs as ccrs
    import matplotlib.pyplot as plt

    # Check that the ALEXI grid looks correct
    tran = ccrs.PlateCarree()
    proj = ccrs.Mercator()
    fig, ax = plt.subplots(subplot_kw=dict(projection=proj), figsize=(10, 5), constrained_layout=True)
    ax.coastlines(color="orangered", linewidth=3)
    ax.gridlines(draw_labels=True)
    ds.isel(time=0).et.plot(ax=ax, transform=tran)

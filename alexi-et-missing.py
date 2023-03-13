"""
Print list of dates in current year where ALEXI ET file is missing
"""
from __future__ import annotations

import re
from datetime import date
from multiprocessing import Pool

import pandas as pd
import requests

base_url = "https://geo.nsstc.nasa.gov/SPoRT/outgoing/crh/4ecostress"

# Get available yjs from the main page
# e.g. `>2022001<`
url = f"{base_url}/"
r = requests.get(url)
r.raise_for_status()
available_yjs = re.findall(r">([0-9]{7})<", r.text)
# TODO: gets two at the bottom that maybe shouldn't (though they seem to work although the files are diff size)
if not available_yjs:
    raise ValueError(
        f"search of {base_url}/ detected no available dates for ALEXI ET",
    )


def check(yj: str) -> tuple[bool, date, str]:
    fn = f"ALEXI_ET_4KM_CONUS_V01_{yj}.dat"
    url = f"{base_url}/{yj}/{fn}"
    ts = pd.to_datetime(yj, format=r"%Y%j")
    date_ = ts.date()
    r = requests.head(url)
    ok = True
    if r.status_code == 404:
        ok = False
    else:
        r.raise_for_status()
    return ok, date_, url


if __name__ == "__main__":
    with Pool() as p:
        res = p.map(check, available_yjs)

    res.sort(key=lambda tup: tup[1])

    n = 0
    for ok, date_, url in res:
        if not ok:
            print(date_, url)
            n += 1
    print(f"{n}/{len(res)} missing ALEXI ET file")

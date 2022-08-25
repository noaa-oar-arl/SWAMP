"""
Print list of dates in current year where ALEXI ET file is missing
"""
import re

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

# TODO: parallel
for yj in available_yjs[-3:]:
    fn = f"ALEXI_ET_4KM_CONUS_V01_{yj}.dat"
    url = f"{base_url}/{yj}/{fn}"
    print(url)
    r = requests.head(url)
    if r.status_code == 404:
        ts = pd.to_datetime(yj, format=r"%Y%j")
        print(yj, str(ts.date()))
    else:
        r.raise_for_status()

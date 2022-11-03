"""
Try MetPy objective analysis routines for CRN.
"""
import pandas as pd
from metpy.interpolate.geometry import dist_2
from metpy.interpolate.points import barnes_point, cressman_point

from dl import get_crn


dates = pd.date_range("2020/09/01", "2020/09/02")

df = get_crn(dates)
print(df)

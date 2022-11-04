"""
Try MetPy objective analysis routines for CRN.
"""
import cartopy.crs as ccrs
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
from metpy.interpolate import interpolate_to_grid, remove_nan_observations

from dl import get_crn

plt.close("all")

# dates = pd.date_range("2020/09/01", "2020/09/02")

df = get_crn(["2020/09/01"])
print(df)

x = df["LONGITUDE"]
y = df["LATITUDE"]
v = df["SOIL_MOISTURE_5_DAILY"].copy()
v.loc[v == -99] = np.nan

x, y, v = remove_nan_observations(x, y, v)

proj = ccrs.Mercator()
tran = ccrs.PlateCarree()
hres = 0.1
levels = np.linspace(0, v.max(), 20)
norm = mpl.colors.Normalize(vmin=0, vmax=v.max())

fig, axs = plt.subplots(
    2,
    3,
    subplot_kw=dict(projection=proj),
    figsize=(16, 7),
    constrained_layout=True,
    sharex=True,
    sharey=True,
)

for i, (t, settings) in enumerate(
    [
        ("nearest", {}),
        ("rbf", dict(rbf_func="gaussian")),
        ("rbf", dict(rbf_func="linear")),
        ("rbf", dict(rbf_func="flat_plate")),
        ("barnes", {}),
        ("cressman", {}),
    ]
):
    ax = axs.flat[i]
    gx, gy, gv = interpolate_to_grid(x, y, v, interp_type=t, hres=hres)
    im = ax.pcolormesh(gx, gy, gv, transform=tran, norm=norm)
    ax.scatter(x, y, c=v, marker="o", ec="0.3", s=70, transform=tran, norm=norm)
    ax.coastlines()
    # ax.gridlines(draw_labels=True)
    ax.set_extent([-130, -65, 25, 50])
    title = t
    if settings:
        s_settings = ", ".join(f"{k}={v!r}" for k, v in settings.items())
        title += f"\n({s_settings})"
    ax.set(title=title)


fig.colorbar(im, ax=axs)

plt.show()

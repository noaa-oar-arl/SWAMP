"""
SWAMP
"""
from pathlib import Path

import numpy as np

HERE = Path(__file__).parent
ORIG = HERE / "orig"

# Define output grid
# NOTE: this is 2.4-km in lat and ~ 7-km in lon
ny, nx = (720, 1150)
lat = np.linspace(25, 50, nx)
lon = np.linspace(-125, -65, ny)

# For now, use the coeffs that already exist
# NOTE: slp is the one that gets used in the current original SWAMP
# NOTE: this array has 39% 0 values and 17% -21.52 values, the rest positive but < 1
slp_coeffs = np.loadtxt(ORIG / "PROCESS_DAILY/slp_weights.txt")
int_coeffs = np.loadtxt(ORIG / "PROCESS_DAILY/int_weights.txt")
assert slp_coeffs.shape == int_coeffs.shape == (ny, nx)

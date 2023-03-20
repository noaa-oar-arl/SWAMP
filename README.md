# SWAMP

NOAA-ARL/ATDD Soil Water Analysis Model Product (SWAMP)

## Development installation

1. Create and activate Conda environment based on [`environment-dev.yml`](./environment-dev.yml).
   ```
   conda env create -f environment-dev.yml
   conda activate swamp-dev
   ```
2. Install `swampy` package using
   ```
   pip install -e . --no-deps
   ```

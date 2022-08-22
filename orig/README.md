# SWAMP
## Repository for the NOAA-ARL/ATDD Soil Water Analysis Model Product (SWAMP) Codes and Run Scripts

## SWAMP Library/Software Dependencies:

 - Linux-Bash/C-Shell, NCL (with fortran/wrapit77 support), and GDAL

 - Recommend creating a stable Anaconda3 environment for SWAMP with NCL and GDAL included

 - `conda create --name swamp_stable`
 - `conda activate swamp_stable`
 - `conda install -c conda-forge ncl`
 - `conda install -c conda-forge gdal`

## SWAMP Usage:

There are five main directories:

MAIN_CRN, PRISM, ALEXI, PROCESS_DAILY, and PROCESS_DAILY_STATION

 - After setup of conda environment with both NCL and GDAL libraries, activate environment:  conda activate swamp_stable
 - Change directory into MAIN_CRN.
 - Setup the setcase.csh script for specific year and run days for SWAMP (can only run over a single year at this point).
 - Run the `./crn_daily_update.sh` script.

The main crn_daily_update.sh script will invoke the following five major steps:

1. Download daily soil/vegetation U.S. CRN data
2. Download and process PRISM precipition data
3. Download and process ALEXI data from NASA
4. Process daily CRN data based on PRISM, ALEXI, and transfer functions
5. Create gridded daily and daily station SWAMP soil moisture products 

## SWAMP Main Routines/Files in this Repository:

 - `MAIN_CRN/crn_daily_update.sh`
 - `MAIN_CRN/setcase.csh`
 - `MAIN_CRN/module_file`
 - `MAIN_CRN/downftp`
 - `MAIN_CRN/getvegsoilnc4swamp`
 - `MAIN_CRN/runscript`
 - `MAIN_CRN/create_crn.ncl`
 - `MAIN_CRN/soil_water.txt`
 - `MAIN_CRN/soil_water_o.txt`
 - `MAIN_CRN/soil_properties.txt`
 - `stationID_lat_lon.txt`
 - `PRISM/runprism`
 - `PRISM/downprism`
 - `PRISM/bil2nc`
 - `ALEXI/runalexi`
 - `PROCESS_DAILY/slp_weights.txt`
 - `PROCESS_DAILY/int_weights.txt`
 - `PROCESS_DAILY/minmax_2010.txt`
 - `PROCESS_DAILY/minmax_2011.txt`
 - `PROCESS_DAILY/minmax_2012.txt`
 - `PROCESS_DAILY/minmax_2013.txt`
 - `PROCESS_DAILY/minmax_2014.txt`
 - `PROCESS_DAILY/minmax_2015.txt`
 - `PROCESS_DAILY/minmax_2016.txt`
 - `PROCESS_DAILY/minmax_2017.txt`
 - `PROCESS_DAILY/minmax_2018.txt`
 - `PROCESS_DAILY/minmax_2019.txt`
 - `PROCESS_DAILY/minmax_2020.txt`
 - `PROCESS_DAILY/swamp.f`
 - `PROCESS_DAILY/swampi.f`
 - `PROCESS_DAILY/weight.f`
 - `PROCESS_DAILY/runit`
 - `PROCESS_DAILY/Air_temp_grid.ncl`
 - `PROCESS_DAILY/Avail_water_depth_grid.ncl`
 - `PROCESS_DAILY/Fract_avail_water_grid.ncl`
 - `PROCESS_DAILY/Precip_grid.ncl`
 - `PROCESS_DAILY/Smois_05cm_grid.ncl`
 - `PROCESS_DAILY/Smois_10cm_grid.ncl`
 - `PROCESS_DAILY/Smois_20cm_grid.ncl`
 - `PROCESS_DAILY/Smois_50cm_grid.ncl`
 - `PROCESS_DAILY/Smois_100cm_grid.ncl`
 - `PROCESS_DAILY/Soiltemp_05cm_grid.ncl`
 - `PROCESS_DAILY/Soiltemp_10cm_grid.ncl`
 - `PROCESS_DAILY/Soiltemp_20cm_grid.ncl`
 - `PROCESS_DAILY/Soiltemp_50cm_grid.ncl`
 - `PROCESS_DAILY/Soiltemp_100cm_grid.ncl`
 - `PROCESS_DAILY/Solar_grid.ncl`
 - `PROCESS_DAILY/Surface_temp_grid.ncl`
 - `PROCESS_DAILY/RH_grid.ncl`
 - `PROCESS_DAILY/Sur_temp_min_grid.ncl`
 - `PROCESS_DAILY/Temp_min_grid.ncl`
 - `PROCESS_DAILY/Temp_max_grid.ncl`
 - `PROCESS_DAILY/Soil_moisture_model_grid_fine3.ncl`
 - `PROCESS_DAILY/Soil_moisture_model_grid_index.ncl`
 - `PROCESS_DAILY/Soil_moisture_model_grid_fine_rel.ncl`
 - `PROCESS_DAILY/Soil_moisture_model_grid_2v.ncl`
 - `PROCESS_DAILY_STATION/statmatch.f`
 - `PROCESS_DAILY_STATION/runit`
 - `PROCESS_DAILY_STATION/Air_temp_grid.ncl`
 - `PROCESS_DAILY_STATION/Avail_water_depth_grid.ncl`
 - `PROCESS_DAILY_STATION/Fract_avail_water_grid.ncl`
 - `PROCESS_DAILY_STATION/Precip_grid.ncl`
 - `PROCESS_DAILY_STATION/Smois_05cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Smois_10cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Smois_20cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Smois_50cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Smois_100cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Soiltemp_05cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Soiltemp_10cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Soiltemp_20cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Soiltemp_50cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Soiltemp_100cm_grid.ncl`
 - `PROCESS_DAILY_STATION/Solar_grid.ncl`
 - `PROCESS_DAILY_STATION/Surface_temp_grid.ncl`
 - `PROCESS_DAILY_STATION/RH_grid.ncl`
 - `PROCESS_DAILY_STATION/Sur_temp_min_grid.ncl`
 - `PROCESS_DAILY_STATION/Sur_temp_max_grid.ncl`
 - `PROCESS_DAILY_STATION/Temp_min_grid.ncl`
 - `PROCESS_DAILY_STATION/Temp_max_grid.ncl`

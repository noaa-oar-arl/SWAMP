#!/bin/csh

#This is the main NOAA-ARL/ATDD SWAMP run/ftp script, which has 5 main components

#User/Common components to set year, dates, and potential other common setup information

source ./setcase.csh

#Load necessary system modules (e.g., gdal and  ncl )  ---Conda virtual environment recommended

source ./module_file

#1.  Download and process daily CRN for SWAMP in respecitve year.
./downftp
echo "finished downftp"

#2.  Download and process daily PRISM for SWAMP in respective year.
cd ../PRISM
./runprism
echo "finished runprism"

#3.   Download daily ALEXI for SWAMP.
cd ../ALEXI
./runalexi
echo "finished runalexi:"

#4.  This calls the main SWAMP processing for daily and daily_station outputs.

cd ../MAIN_CRN
./getvegsoilnc4swamp
./runscript
echo "finished runscript"

echo "SWAMP Completed!"

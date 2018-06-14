# GPCC_Interpolation_Scripts
A repository containing the scripts and auxiliary files needed to do interpolate in situ data using ordinary block Kriging. The methods are identical to the GPCC Full Data Daily dataset.

Below is a description of each script.

## Datensatz-erzeugen.sh

This is the "controller script". Literally, the name translates to "record-production". 

At the start of this script you specify the interpolation resolution ("Gitter") and the start and end dates of interpolation. For subdaily changes within this script may need to be made so the script calls the kriging.f90 (interpolation) script once every hour (or 3h..) instead of once a day. The script has been set up so these are the only changes one would need to make to interpolate daily data as long as the raw data is in the right format. 

In the section that follows immediately, the script sets up some date variables and performs some sanity checks on the dates before removing any existing compliled fortran output files. 

The function daten_holen() translates to "get_data" and as the name suggests gets the raw in situ data, however, in our case we pre-arrange the in situ data in the right format and store them in a directory which we specify later in this script. As a result I have commented out the section of this script where this function is called (Line 248).

The next function, interpolieren(), is responsible for the calling the controller script for one days (or one instance's) interpolation. It gets the location of the netcdf files of monthly gridded data which are superimposed onto the interpolated anomalies to retrieve absolute values. In our case we will provide locations of files that have ones stored in each grid location (since we would like to interpolate absolute values). 

In the next section before the while loop the two most important variables are specified: the path to the input files (Ordner_Eingangsdateien) and the path to the output files (Ordner_Erg). I also added some if statements to create the output directory and its subdirectories if they do not already exist.

Finally the while loop loops over each date and calls the interpolieren() function. For subdaily interpolation this loop will need to be modified so it loops over hours instead. 

## AUFRUF-KRIGING.sh

This bash script calls the actual fortran interpolation script (kriging.f90; or more acurately the compilled comp-kriging_f90.out). It also outputs the parameters for interpolation in a text file called dates.txt that is read in by kriging.f90. Ideally nothing is modified in this script, however, for subdaily interpolation certain variables may need to be modified to handle hourly data as opposed to daily data. However, it is possible that with appropriate modfication in the Datensatz-erzeugen.sh script nothing will need to change here.

The interpolation parameters outputted can be tuned at the beginning of this script. 

The large commented out section at the bottom just creates plots of the interpolated output, which was unnecessary in my case.

## LAM_1.0_D_R, PHI_1.0_D_R and SEA_1.0_D_R

LAM_1.0_D_R is the longitude grid information (I think), PHI_1.0_D_R contains the latitude information and SEA_1.0_D_R contains the land sea mask information. 

## Subroutinen Subroutinen_FGD

The directories contain fortran scripts for the subroutines called by kriging.f90. Both directories contain identical files. It is possible that the scripts work fine with only one directory (most likely the Subroutinen_FGD because I have only ever seen these being called), but I have never tried this.

## kriging.f90

The actual interpolation script which is compiled by the controller scripts above. In here, the variagrams are calculated and the raw data is interpolated. I have not paid much attention to what goes on in here. I trusted it all works fine. 

## Input file for interpolation

The directory IN/ contains a sample input file containing the raw in situ data for interpolation. The input files are organised by day and contains four columns Latitude, Longitude, in situ value and monthly value (used for calculating anomalies). For subdaily interpolation, the files will be organised by hour and the monthly values column should be filled with 1.0 for absolute value interpolation. 



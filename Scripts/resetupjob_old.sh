#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/RUNS
folder=$1

cd $wd/$folder
jobnum=`tail -n 1 kriging.jobnum | awk '{print $2}' | sed 's/.xcepbs00//g'`
sed '231s/.*/if [ ! -d "$Ordner_Erg" ]; then mkdir $Ordner_Erg; fi/' Datensatz-erzeugen.sh > tmp
sed -i '232s#.*#if [ ! -d "$Ordner_Erg"/Error ]; then mkdir "$Ordner_Erg"/Error; fi#' tmp
sed -i '233s#.*#if [ ! -d "$Ordner_Erg"/Err_K ]; then mkdir "$Ordner_Erg"/Err_K; fi#' tmp
sed -i '234s#.*#if [ ! -d "$Ordner_Erg"/Stat-verteilung ]; then mkdir "$Ordner_Erg"/Stat-verteilung; fi#' tmp
sed -n '230,235p' tmp
echo Looks good? [Y/y]
read response
if [ response=="Y" -o response=="y" ]
then
	mv tmp Datensatz-erzeugen.sh
	chmod +x Datensatz-erzeugen.sh
fi
rm dates.txt
rm comp-kriging_f90.out
mv kriging.out kriging."$jobnum".out
cd $wd

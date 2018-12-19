#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

for HME in ALL #FORTY
do
	echo Dirs: A
	for y in `seq 1950 1955`
	do
		echo Year: $y
		cd $wd/$HME/"$y"a
		sed -i "s/Start=195001/Start="$y"01/g" Datensatz-erzeugen.sh
		sed -i "s/Ende=19501231/Ende="$y"0630/g" Datensatz-erzeugen.sh
		sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
		sed -i "s/XYZ/"$y"a/g" kriging.job
		sed -i "s/HME/"$HME"/g" kriging.job
	done
	echo Dirs: B
	for y in `seq 1950 1955`
	do
		echo Year: $y
		cd $wd/$HME/"$y"b
		sed -i "s/Start=195001/Start="$y"07/g" Datensatz-erzeugen.sh
		sed -i "s/Ende=195012/Ende="$y"12/g" Datensatz-erzeugen.sh
		sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
		sed -i "s/XYZ/"$y"b/g" kriging.job
		sed -i "s/HME/"$HME"/g" kriging.job
	done
	cd $wd
done

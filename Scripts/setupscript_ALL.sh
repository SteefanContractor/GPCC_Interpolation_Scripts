#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.2

for HME in ALL #FORTY
do
	for y in `seq 2006 2013`
	do
			echo Dirs: A
			echo Year: $y
			cd $wd/$HME/"$y"a
			sed -i "s/Start=195001/Start="$y"01/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=195012/Ende="$y"03/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"a/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
			echo Dirs: B
			echo Year: $y
			cd $wd/$HME/"$y"b
			sed -i "s/Start=195001/Start="$y"04/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=19501231/Ende="$y"0630/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"b/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
			echo Dirs: C
			echo Year: $y
			cd $wd/$HME/"$y"c
			sed -i "s/Start=195001/Start="$y"07/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=19501231/Ende="$y"0930/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"c/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
			echo Dirs: D
			echo Year: $y
			cd $wd/$HME/"$y"d
			sed -i "s/Start=195001/Start="$y"10/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=195012/Ende="$y"12/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"d/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
	done
	cd $wd
done

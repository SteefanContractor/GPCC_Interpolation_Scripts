#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.2

for HME in ALL #FORTY
do
	for y in `seq 1950 2016`
	do
		if [[ ("$y" -ge 1956  &&  "$y" -le 1958) || ("$y" -ge 1962  && "$y" -le 1977) || ("$y" -ge 1980 && "$y" -le 1983) || ("$y" -ge 1987 && "$y" -le 1990) || ("$y" -eq 1994) || ("$y" -ge 2006 && "$y" -le 2016) ]]
		then 
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
		elif [[ ("$y" -eq 1959) || ("$y" -eq 1961) || ("$y" -ge 1978 && "$y" -le 1979) || ("$y" -ge 1984 && "$y" -le 1986) || ("$y" -ge 1991 && "$y" -le 1993) || ("$y" -eq 1996) || ("$y" -eq 1999) ]]
		then
			echo Dirs: A
			echo Year: $y
			cd $wd/$HME/"$y"a
			sed -i "s/Start=195001/Start="$y"01/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=19501231/Ende="$y"0430/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"a/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
			echo Dirs: B
			echo Year: $y
			cd $wd/$HME/"$y"b
			sed -i "s/Start=195001/Start="$y"05/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=195012/Ende="$y"08/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"b/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
			echo Dirs: C
			echo Year: $y
			cd $wd/$HME/"$y"c
			sed -i "s/Start=195001/Start="$y"09/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=195012/Ende="$y"12/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"c/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
		else
			echo Dirs: A 
			echo Year: $y
			cd $wd/$HME/"$y"a
			sed -i "s/Start=195001/Start="$y"01/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=19501231/Ende="$y"0630/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"a/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
			echo Dirs: B
			echo Year: $y
			cd $wd/$HME/"$y"b
			sed -i "s/Start=195001/Start="$y"07/g" Datensatz-erzeugen.sh
			sed -i "s/Ende=195012/Ende="$y"12/g" Datensatz-erzeugen.sh
			sed -i "s/HME/"$HME"/g" Datensatz-erzeugen.sh
			sed -i "s/XYZ/"$y"b/g" kriging.job
			sed -i "s/HME/"$HME"/g" kriging.job
		fi
	done
	cd $wd
done

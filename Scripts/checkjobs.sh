#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/RUNS
#echo Dirs: A
for y in `seq 1971 2013`
do
	for p in a b
	do
		echo $y$p
		cd $wd/"$y""$p"
		grep -i walltime kriging.out
		grep -i memory kriging.out
		grep "not created. The script will continue" kriging.out
		cd $wd
	done
done

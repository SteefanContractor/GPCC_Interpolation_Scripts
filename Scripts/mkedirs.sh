#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

for HME in ALL #FORTY
do
	for y in `seq 1950 1955`
	do
		cp -r $wd/template_dir $wd/$HME/"$y"a
		cp -r $wd/template_dir $wd/$HME/"$y"b
	done
done

#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.2
HME=FORTY

for d in `sed -n '1,7p' $wd/remaining_"$HME"jobs.txt`
do
	echo $d 
	cd $wd/$HME/"$d"
	./submitJob.sh
	cd $wd
done
sed -n '1,7p' $wd/remaining_"$HME"jobs.txt >> $wd/submitted_"$HME"jobs.txt
sed -i '1,7d' $wd/remaining_"$HME"jobs.txt
#echo Dirs: B
#for y in `seq 1950 1969`
#do
#	echo Year: $y
#	cd $wd/"$y"b
#	./submitJob.sh
#	cd $wd
#done

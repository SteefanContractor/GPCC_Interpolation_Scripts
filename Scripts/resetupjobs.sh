#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

while read -r i
do
	year=${i:7:4}
	dir=${i:0:5}
	monthday=${i:11:4}
	monthday=$((10#$monthday))
	newdate=`printf "%04d%04d" $year $((monthday+1))`
	echo $year $dir $monthday $newdate
	if [ ! -d $wd/ALL/"$year"c ]; then
		newdir="$year"c
		mkdir $wd/ALL/$newdir
		echo $newdir >> $wd/newdirs.txt
	else
		newdir="$year"d
		mkdir $wd/ALL/$newdir
		echo $newdir >> newdirs.txt
	fi
	cp $wd/ALL/$dir/*.sh $wd/ALL/$dir/*.f90 $wd/ALL/$dir/*.job $wd/ALL/$newdir/
	cp -r $wd/ALL/$dir/LAM* $wd/ALL/$dir/PHI* $wd/ALL/$dir/SEA* $wd/ALL/$dir/Subroutinen* $wd/ALL/$newdir/
	sed -i "26s/.*/\tStart=$newdate/" $wd/ALL/$newdir/Datensatz-erzeugen.sh
	sed -i "s/$dir/$newdir/g" $wd/ALL/$newdir/kriging.job
	sed -i 's/t=$Tag_start/t=$(( 10#$Tag_start ))/g' $wd/ALL/$newdir/Datensatz-erzeugen.sh
	sed -i 's/m=$Monat_start/m=$(( 10#$Monat_start ))/g' $wd/ALL/$newdir/Datensatz-erzeugen.sh
done < $wd/ALL_restartJobs.txt	

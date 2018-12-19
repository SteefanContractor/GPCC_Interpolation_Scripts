#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.0/ALL
for y in `seq 1968 1972`
do
	for p in a b
	do	
		cd $wd/$y$p
		jobid=`cat kriging.jobnum | tail -n 1| cut -d ' ' -f 2`
		qdel $jobid
	done
done
cd $wd

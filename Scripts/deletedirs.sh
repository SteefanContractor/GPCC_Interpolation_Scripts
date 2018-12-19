#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.0

for i in `cat $wd/ALL_restartJobs.txt`
do
        year=${i:14:4}
	rm -r $wd/ALL/"$year"c
	rm -r $wd/ALL/"$year"d
done

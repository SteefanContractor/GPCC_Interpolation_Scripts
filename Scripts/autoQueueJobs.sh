#!/bin/bash

WD=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.2

while true
do
	numJobsRunning=`qstat -u routwzn | grep -c lc_big` #sed '1,5d' | wc -l`
	echo `date '+%d%m%Y-%T'`UTC:  $numJobsRunning jobs running
	if [ "$numJobsRunning" -le 6 ]; then
		echo less than 7 jobs. Queuing more
		$WD/Scripts/submitjobs.sh
	fi
	# sleep for 900 seconds so script runs every 15minutes
	sleep 900
done

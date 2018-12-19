#!/bin/bash

WD=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

for i in `cat $WD/finished_FORTYjobs.txt`
do
	endDate=`grep Ende="${i:0:4}" $WD/FORTY/"$i"Datensatz-erzeugen.sh | cut -c 7-14`
	echo $i last date: $endDate
	if [ -f $WD/FORTY/"$i"OUT/$endDate.txt ] 
	then
		echo finished: All days interpolated
	else
		lastFinished=`ls $WD/FORTY/"$i"OUT/*.txt | tail -n 1`
		lastFinished=`basename $lastFinished`
		echo unfinished: last finished is $lastFinished
		sed -i "/${i:0:5}/d" $WD/finished_FORTYjobs.txt
		echo $i $lastFinished >> unfinished_FORTYjobs.txt
	fi
done

#!/bin/bash

WD=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

for i in `cat $WD/ALL_restartJobs.txt`
do
	mv $WD/ALL/"$i"OUT $WD/ALL/"$i"OUT_old
	sed -i 's/t=$Tag_start/t=$(( 10#$Tag_start ))/g' $WD/ALL/"$i"Datensatz-erzeugen.sh                                                                                                                                                                                 
        sed -i 's/m=$Monat_start/m=$(( 10#$Monat_start ))/g' $WD/ALL/"$i"Datensatz-erzeugen.sh
done	

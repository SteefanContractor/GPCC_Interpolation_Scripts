#!/bin/bash

WD=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

for d in `cat $WD/remaining_ALLjobs.txt`
do
	echo $d
	sed -i 's/t=$Tag_start/t=$(( 10#$Tag_start ))/g' $WD/ALL/"$d"Datensatz-erzeugen.sh
	sed -i 's/m=$Monat_start/m=$(( 10#$Monat_start ))/g' $WD/ALL/"$d"Datensatz-erzeugen.sh
done

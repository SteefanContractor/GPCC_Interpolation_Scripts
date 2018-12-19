#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/VERSION1.1

for d in 1980b # `cat $wd/finished_FORTYjobs.txt`   # FORTY/1963a FORTY/1963b FORTY/1959d FORTY/1959e FORTY/1959f  #`cat FORTY_dirs.txt`
do
	d=${d:0:5}
	echo Now copying files in $d
#	rsync $wd/FORTY/$d/OUT/*.txt z3289452@ccrc217.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/VERSION1.1/ASCII_output/FORTY_1.2/
#	rsync $wd/FORTY/$d/OUT/Error/*.dat z3289452@ccrc217.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/VERSION1.1/ASCII_output/FORTY_1.2/Error/
	rsync $wd/FORTY/$d/OUT/Err_K/*.dat z3289452@ccrc217.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/VERSION1.1/ASCII_output/FORTY_1.2/Err_K/
	rsync $wd/FORTY/$d/OUT/Stat-verteilung/*.dat z3289452@ccrc217.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/VERSION1.1/ASCII_output/FORTY_1.2/Station-distribution/
done

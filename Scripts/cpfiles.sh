#!/bin/bash

wd=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/RUNS

for y in `seq 1950 2013`
do
	echo $y
	for p in a b
	do
		sshpass -p $(cat rsync_pass) rsync -avz $wd/$y$p/OUT/Error/*.dat z3289452@ccrc163.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/ASCII_output/ALL/Error/ #$wd/OUTDIR/
		sshpass -p $(cat rsync_pass) rsync -avz $wd/$y$p/OUT/Err_K/*.dat z3289452@ccrc163.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/ASCII_output/ALL/Err_K/ #$wd/OUTDIR/
		sshpass -p $(cat rsync_pass) rsync -avz $wd/$y$p/OUT/Stat-verteilung/*.dat z3289452@ccrc163.ccrc.unsw.edu.au:/srv/ccrc/data11/z3289452/CCRCGlobalGriddedDailyPrecip/ASCII_output/ALL/Station-distribution/ #$wd/OUTDIR/
		#rsync -av $wd/$y$p/OUT/Error/ $wd/OUTDIR/Error/
		#rsync -av $wd/$y$p/OUT/Err_K/ $wd/OUTDIR/Err_K/
		#rsync -av $wd/$y$p/OUT/Stat-verteilung/ $wd/OUTDIR/Stat-distribution/
	done
done

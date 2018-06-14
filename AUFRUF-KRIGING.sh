#!/bin/bash
#
#
# Skript zur Interpolation von Stationswerten
# je nach eingabe werden relativwerte oder Absolutwerteinterpoliert
# je nach eingabe wird auf Gitterpunkte oder auf Stationen interpoliert
# Radius und ACF Parameter werden vom Nutzer eingegeben
# Datum des gewünschten Tags wird eingegeben
# Abbildung der Interpolationsergebnisse und der Messwerte werden automatisch erzeugt

# Skript erzeugt am 14.05.2012 von KL


# Bei Skriptaufruf das gewünschte Datum, ob relativwerte oder absolutwerte und ob auf Gitterpunkte oder Messpunkte interpoliert werden soll



# ***************************************************************************************************************************************************
# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
# ***************************************************************************************************************************************************

# Hier gewuenschte Parameter ändern

     #rel_abs=rel	     # abs    #rel
     Gitter_Pkt='Gitter'     # 'Gitter'  #'Messpk'      #'Messpk'  	     #Gitter #Messpk
     Radius=200 	     # ist zur Zeit im Kriging variabel eingestellt, (wird angepasst damit überall hin interpoliert wird, nach Spheremap)
     rel_abs=rel 	     # abs oder #rel für Absolutwerte oder Relativwerte die Interpoliert werden sollen
     ACFA=0.014 	     
     ACFB=0.726
     MinSta=04
     MaxSta=10
     raster=$2	     # 0.22 oder 1
     datei=$3   #"/media/x18914/kirstin/Eingangsdateien/Tagesdaten/daily_$Datum.xyz"	
     Datum=$1   #$Jahr$Monat$Tag
     Datei_MW_Raster=$4
# ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~


LANG=C

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Interpolation starten


			clear
			echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
			echo " 					   $(date '+%d.%m.%Y - %T'):  Start der Interpolation fuer $Datum"
			echo

	
		#***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~
		#~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***

			
			
			Ergebnisdatei=OUT/$Datum.txt



		#***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~
		#~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***

			#***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~#
			# 	ini-Datei für Kriging erzeugen  (dates_2.txt )	    #
			#~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~**#
	
			echo "'$datei'" 	 > dates.txt
			echo "$Datum" 		>> dates.txt	# Datum jjjjmmdd
			echo "$Radius" 		>> dates.txt	# Radius	
			echo "$ACFA" 		>> dates.txt	# ACF A
			echo "$ACFB" 		>> dates.txt	# ACF B
			echo "$rel_abs" 	>> dates.txt	# "rel" oder "abs"
			echo "$Gitter_Pkt" 	>> dates.txt	# "Gitter" oder "Messpk"
			echo "$MinSta" 		>> dates.txt # Mindeste Anzahl an verwendeten Stationen
			echo "$MaxSta" 		>> dates.txt # Maximale Anzahl an verwendeten Stationen
			echo "'$Ergebnisdatei'" >> dates.txt	# Ergebnisdatei
			echo "'$Datei_MW_Raster'">> dates.txt	# Datei mit den Monatswerten
			if [ $raster == '0.22' ]
			then
			echo "212" >> dates.txt	# Anzahl Raster in x-Richtung
			echo "206" >> dates.txt	# Anzahl Raster in y-Richtung
			elif [ $raster == '1.0' ]
			then
			echo "360" >> dates.txt	# Anzahl Raster in x-Richtung
			echo "180" >> dates.txt	# Anzahl Raster in y-Richtung
			elif [ $raster == '0.5' ]
			then
			echo "720" >> dates.txt	# Anzahl Raster in x-Richtung
			echo "360" >> dates.txt	# Anzahl Raster in y-Richtung
			elif [ $raster == '2.5' ]
			then
			echo "144" >> dates.txt	# Anzahl Raster in x-Richtung
			echo "72" >> dates.txt	# Anzahl Raster in y-Richtung
			else
			echo "Keine gueltige Rasterweite angegeben"
			exit
			fi			


		#***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***
		#	 Kriging Quellcode kompellieren und laufen lassen:
		#~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~

			# Pruefen ob die Ergebnisdatei bereits existiert und nachfragen ob sie Ueberschrieben werden soll
			if [ -f $Ergebnisdatei ]
			then
				echo "Output file exists. Overwrite?"
				read ueberschreiben
				case $ueberschreiben in
					[N,n]) exit
					;;
					[J,j,Y,y]*)
					echo "The output file will be overwritten. To stop interrupt now. (Programm starts in 5 seconds!)"	
					sleep 5
					rm $Ergebnisdatei
					;;
					*) 
					echo 'Enterr "J", "Y" oder "N" please!'
					exit
					;;
				esac
		
			fi	



			# Pruefen ob die Datei mit den Messwerten existiert und wenn ja dann Fortran-Programm Kompellieren. Wenn das schief ging Skript abbrechen
			# Sonst Fortran-Programm starten
			if [ -f $datei ] 
			then
				./comp-kriging_f90.out
			else
				echo
				echo '----------------'
				echo "The file $datei does not exist; The script will continue"
				echo '----------------'
				echo
				#exit 1
			fi


			#Pruefen ob die Ergebnisdatei erzeugt wurde, ansonsten Programmabbruch
			if [ -f $Ergebnisdatei ]
			then
				echo "$(date): Interpolation output produced"
			else
				echo "$(date): Output file $Ergebnisdatei not created. The script will continue!"
				#exit 1
			fi





#***********************************************************************************************
#***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  
#  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  
#***********************************************************************************************
# Abbildung erzeugen:


# set -k
# 
# if [ -f $Ergebnisdatei ]
# then
# 		
# 			
# 
# 
# 
# #Abbildung mit Anzahl Stationen erzeugen:	
# #-------------------------------------------
# 
# cd Abbildungen
# cp ../Stat-verteilung.dat  ausgabedatei.dat			
# 
# 	Datei_ein='ausgabedatei.dat'
# 	Datei_Abb='Kontrollabbildung'
# 	Legende='NUMGAUGE'
# 	T1='Anzahl Messungen im Raster'
# 	T2=$Datum
# 	#T3='Europa'
# 
# 	./produce_grads_station.sh stdat=$Datei_ein  out=$Datei_Abb art=$Legende  res=high polit=yes  format=lon,lat,val t1=$T1 t2=$T2 #t3=$T3
# 	
# 	rm ausgabedatei.dat
# 	
# 	mv GIF/Kontrollabbildung.gif ../Ergebnisdateien/precip_Statverteilung_$Datum.gif
# 
# 	#display ../Ergebnisdateien/precip_Statverteilung_$Datum.gif
# cd ..
# 			
# 			
# 			
# #Abbildung mit den Messwerten erzeugen
# #-------------------------------------------
# 
# 
# cd Abbildungen
# 
# cp $datei ausgabedatei.dat			
# 
# ./Extrakt_Spalte.out << EOF
# ausgabedatei.dat
# ausgabedatei2.dat
# 1
# 32
# 1
# j
# EOF
# 			
# 
# Datei_ein='ausgabedatei2.dat'
# Datei_Abb='Kontrollabbildung'
# Legende='DAYPRECIP_xxx'
# T1='Messwerte'
# T2=$Datum
# #T3='Europa'
# 
# ./produce_grads_station.sh stdat=$Datei_ein  out=$Datei_Abb art=$Legende  res=high polit=yes  format=lat,lon,val t1=$T1 t2=$T2 #t3=$T3
# 
# rm ausgabedatei.dat
# rm ausgabedatei2.dat
# 
# mv GIF/Kontrollabbildung.gif ../Ergebnisdateien/precip_Messwert_$Datum.gif
# 
# #display ../Ergebnisdateien/precip_Messwert_$Datum.gif
# cd ..
# 
# 
# 
# 
# 
# 
# 
# 
# #Abbildung mit den Interpolationsfehlern Werten erzeugen
# #-------------------------------------------
# 
# 
# Dateiname_Abb2="Testabbildung_Kriging"
# Var='Interpolationsfehler'
# ./Skript_aufruf_abb_erzeugen.sh  $Datum $Dateiname_Abb2 $raster $Var
# 
# mv Abbildungen/$Dateiname_Abb2.gif Ergebnisdateien/abb_precip_err_${raster}_$Datum.gif
# 
# #Abbildung mit den Interpolierten Werten erzeugen
# #-------------------------------------------
# 
# 
# Dateiname_Abb2="Testabbildung_Kriging"
# Var='Interpolation'
# ./Skript_aufruf_abb_erzeugen.sh  $Datum $Dateiname_Abb2 $raster $Var
# 
# mv Abbildungen/$Dateiname_Abb2.gif Ergebnisdateien/abb_precip_int_${raster}_$Datum.gif
# 
# 
# 
# 
# 			# Aufraeumen
# 			rm dates.txt
# 			mv interpol_kriging.txt Ergebnisdateien/precip_int_${raster}_$Datum.dat
# 			mv Error.dat Ergebnisdateien/precip_stabw_${raster}_$Datum.dat
# 			mv Stat-verteilung.dat Ergebnisdateien/precip_stat_${raster}_$Datum.dat
# 			mv Err_K.dat Ergebnisdateien/precip_kriging_err_${raster}_$Datum.dat
# 
# 
# 			
# 			mv Ergebnisdateien/precip_Messwert_$Datum.gif Ergebnisdateien/abb_precip_mes_${raster}_$Datum.gif
# 			#mv Ergebnisdateien/precip_interp_${raster}_$Datum.gif Ergebnisdateien/abb_precip_int_${raster}_$Datum.gif
# 			mv Ergebnisdateien/precip_Statverteilung_$Datum.gif Ergebnisdateien/abb_precip_stat_${raster}_$Datum.gif
# 			#mv Ergebnisdateien/precip_err_${raster}_$Datum.gif Ergebnisdateien/abb_precip_err_${raster}_$Datum.gif
# fi
# 		



echo
echo "End of Kriging Setup script"
echo


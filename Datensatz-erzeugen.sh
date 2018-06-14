#!/bin/bash

# Skript das für ein gewünschtes Datum und Rasterweite einen Datensatz erzeugt





#*****************************************************************************************************************************************************************
#*****************************************************************************************************************************************************************
#																				**
# 			PARAMETER BITTE EINSTELLEN:														**
#		     ------------------------------														**
#																				**
#	(weitere Parameter sind in dem Skript zum Aufrufen der Interpolation einstellbar)									**
#	(Zur Zeit eingestellt: Kriging mit Relativwerten auf ein Raster mit flexiblem Suchradius )								**
#	(Als gerasterte Monatswerte werden GPCC-Full-Data Produkte verwendet (alternativ in diesem Skript Anpassen (ca. zeile 178 Datei_MW=...)) )		**
#																				**
#																				**
# Gitteraufloesung: 1.0 Grad oder 0.5 Grad  oder 2.5 oder 0.22(rotiert)  (Gitter="1.0" oder Gitter="0.5...")							**
#																				**
	Gitter="1.0"
#																				**
# Zeitraum: Startdatum und Enddatum im Format YYYYMMTT														**
#																				**
	Start=19500101
	Ende=19501231
#																				**
#																				**
#*****************************************************************************************************************************************************************
#*****************************************************************************************************************************************************************





#						SKRIPT BEGINN:
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#
# Fuer jeden einzelnen Tag Datum erzeugen, die Daten aus der Datenbank holen und Interpolation starten; Nicht existierende Tage (z.b. 31.Februar) werden im Skript zum Daten
# holen und im Skript zum interpolieren uebergangen
#
#


LANG=C
# Variablen für das Datum setzen:
#--------------------------------
Jahr_start=$( echo $Start | cut -c 1-4 )
Jahr_ende=$( echo $Ende | cut -c 1-4 )
Monat_start=$( echo $Start | cut -c 5-6 )
Monat_ende=$( echo $Ende | cut -c 5-6 )
Tag_start=$( echo $Start | cut -c 7-8 )
Tag_ende=$( echo $Ende | cut -c 7-8 )

Tage=( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 )
Monate=( 00 01 02 03 04 05 06 07 08 09 10 11 12 )
Jahr=$Jahr_start

Tag=$Tag_start
t=$(( 10#$Tag_start ))
Monat=$Monat_start
m=$(( 10#$Monat_start ))
Jahr=$Jahr_start

Datum="$Jahr$Monat$Tag"
Datum_ende="$Jahr_ende$Monat_ende$Tag_ende"
z=1	# Zähler der eine Endlosschleife verhindern soll; Schleife ist auf 55000 Durchläufe begrenzt ( entspricht ca. 150 Jahre mit Tageswerten! )


# Pruefen ob der gewuenschte Zeitraum ok ist:
#--------------------------------------------
if [ $Jahr_ende -lt $Jahr_start ] || ( [ $Jahr_ende -eq $Jahr_start ] && [ $Monat_start -gt $Monat_ende ] ) || ( [ $Jahr_ende -eq $Jahr_start ] && [ $Monat_start -eq $Monat_ende ] && [ $Tag_start -gt $Tag_ende ] )
then
	echo " Bitte das Datum prüfen für das der Niederschlag interpoliert werden soll"
	echo " Der angegebene Zeitraum ist: $Tag_start.$Monat_start.$Jahr_start  bis $Tag_ende.$Monat_ende.$Jahr_ende"
	exit 1

elif [ $Tag_start -gt 31 ] || [ $Tag_ende -gt 31 ] || [ $Monat_start -gt 12 ] || [ $Monat_ende -gt 12 ]
then

	echo " Bitte das Datum prüfen für das der Niederschlag interpoliert werden soll -- 2"
	echo " Der angegebene Zeitraum ist: $Tag_start.$Monat_start.$Jahr_start  bis $Tag_ende.$Monat_ende.$Jahr_ende"
	exit 1
fi 




# Fortran-Programme kompellieren; damit keine Fehler passieren zunächst alte Version loeschen
#---------------------------------------------------------------------------------------------
# if [ -f MIRAKEL-DATEN-HOLEN/comp-verknuepfen-d-m.out ]
# then
# 	rm MIRAKEL-DATEN-HOLEN/comp-verknuepfen-d-m.out
# fi
# gfortran -static MIRAKEL-DATEN-HOLEN/verknuepfen_m_d.f90 -o MIRAKEL-DATEN-HOLEN/comp-verknuepfen-d-m.out
# 
# if [ -f MIRAKEL-DATEN-HOLEN/comp-verknuepfen-d-m.out ]
# then
# 	echo 'Fortran-Programm zum Verknuepfen von MW und TW aus MIRAKEL kompelliert!'
# 	echo
# else
# 	echo 'Fortran-Programm zum Verknuepfen von MW und TW aus MIRAKEL wurde nicht ordentlich kompelliert!'
# 	exit 1
# fi



# Fortran Programm zur Interpolation Kompellieren und prüfen ob es erfolgreich war.
if [ -f 'comp-kriging_f90.out' ]
then
	rm comp-kriging_f90.out
fi


gfortran -static kriging.f90 -o comp-kriging_f90.out
if [ -f 'comp-kriging_f90.out' ]
then
	echo 'Fortran-Programm for Interpolation compilled!'
	echo
else
	echo 'Fortran-Programm for Interpolation was not properly compilled!'
	exit 1

fi



#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function daten_holen {
	# Daten aus der Datenbank holen und Datei mit Monats- und Tageswerten erzeuen
	#----------------------------------------------------------------------------
	cd MIRAKEL-DATEN-HOLEN/
	
	# Prüfen ob der Monatswert bereits vorhanden ist dann nur TW holen, sonst beides; Alle Dateien erst ganz am ende löschen/aufraeumen
	if [ -f STATION_DATA/monthly_$Jahr$Monat.dat ] 
	then
		produce_daily_analysis.sh $Tag $Monat $Jahr				# Tageswerte holen
	else	
		combine_daily_monthly_height_normal.sh $Tag $Monat $Jahr		# Monatswerte UND Tageswerte holen
	fi		
	
	
	
	Anz_Stat_D=$(wc -l STATION_DATA/daily_$Jahr$Monat$Tag.xyz) > Dateien.txt
	Anz_Stat_M=$(wc -l STATION_DATA/monthly_$Jahr$Monat.id_lon_lat_hei_val_snormal_rnormal) 
	
	# Einstellungen fuer Fortran Programm um MW und TW zu verknuepfen in Ini-Datei schreiben:
	#-----------------------------------------------------------------------------------------
	echo $Anz_Stat_D >  Dateien.txt
	echo $Anz_Stat_M >> Dateien.txt
	echo "'STATION_DATA/daily_$Jahr$Monat$Tag.xyz'" >> Dateien.txt		# Datei mit TW
	echo "'STATION_DATA/monthly_$Jahr$Monat.id_lon_lat_hei_val_snormal_rnormal'" >> Dateien.txt	# Datei mit MW
	echo "'/media/x18913/DAPACLIP_global/DATEN/DATEN-AUS-MIRAKEL/Daten_$Zeit_Datenholen/daily_$Jahr$Monat$Tag.xyz'" >> Dateien.txt	# Datei mit verknuepften Ergebnissen


	#Dateien mit Monatswerten und Tageswerten verknüpfen:
	#----------------------------------------------------
	echo
	echo " Dateien mit Monatswerten und Tageswerten verknüpfen:"
	echo "------------------------------------------------------------------------------"
	echo
	
	./comp-verknuepfen-d-m.out
		
	head Kontrolldat.txt >> Kontrolldatei_GHCN.txt
	rm Kontrolldat.txt
	
	# Aufraeumen:
	#--------------	
	if [ -f STATION_DATA/daily_$Jahr$Monat$Tag.sel ]
	then
		rm STATION_DATA/daily_$Jahr$Monat$Tag.sel
	fi
	if [ -f STATION_DATA/daily_$Jahr$Monat$Tag.dat ]
	then
		rm STATION_DATA/daily_$Jahr$Monat$Tag.dat
	fi
	if [ -f STATION_DATA/daily_$Jahr$Monat$Tag.info	 ]
	then
		rm STATION_DATA/daily_$Jahr$Monat$Tag.info	
	fi
	if [ -f Dateien.txt ]
	then
		rm Dateien.txt
	fi
	
	cd ..

}
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function interpolieren {
	if [ -f $Ordner_Eingangsdateien/$Jahr$Monat$Tag.txt ]
	then
		if [ $Gitter == "0.5" ] || [ $Gitter == "0.22" ]
		then
			Datei_MW="/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/MONTHLY_GRIDS/gpcc_full_data_v007_05_degree_$Monat$Jahr" #"/media/x18913/DAPACLIP_global/DATEN/MW-GERASTERT/gpcc_full_data_v007_05_degree_$Monat$Jahr"
		elif [ $Gitter == "1.0" ]
		then 
			Datei_MW="/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/MONTHLY_GRIDS/gpcc_full_data_v007_10_degree_$Monat$Jahr" #"/media/x18913/DAPACLIP_global/DATEN/MW-GERASTERT/gpcc_full_data_v007_10_degree_$Monat$Jahr"
		elif [ $Gitter == "2.5" ]
		then 
			Datei_MW="/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/MONTHLY_GRIDS/gpcc_full_data_v007_25_degree_$Monat$Jahr" #"/media/x18913/DAPACLIP_global/DATEN/MW-GERASTERT/gpcc_full_data_v007_25_degree_$Monat$Jahr"
		else
			echo "Keine Passende Monatswerte_Datei gefunden  (Gitter: $Gitter ) "
			exit 1
		fi
		
		if [ -f $Datei_MW ] 
		then
# 			cd KRIGING/
				./AUFRUF-KRIGING.sh $Datum $Gitter $Ordner_Eingangsdateien/$Jahr$Monat$Tag.txt $Datei_MW
# 			cd ..
		else
			echo "No monthly data available for the period"
		fi
	else
		echo "No data available for date $Datum"
	fi

}
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------



# Ordner erstellen in den die aus MIRAKEL-extrahierten Daten und Ergebnisdateien geschrieben werden:
#-----------------------------------------------------------------------------------------------------
Zeit_Datenholen=$( date '+%Y%m%d_%H-%M')
Ordner_Eingangsdateien=/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/MASTER/MSTR2/HME/CONCATENATED_V1_2 #/media/x18913/DAPACLIP_global/DATEN/DATEN-AUS-MIRAKEL/Daten_$Zeit_Datenholen
Ordner_Erg=OUT #/lustre1/rwork2/routwzn/smukeshk/INTERPOLATION/KRIGING/OUT #/media/x21045/COUNTRIES/Steefan/scontractor/MasterList/KRIGING/OUT #/media/x18913/DAPACLIP_global/DATEN/ERGEBNISDATEIEN/ERGEBNISSE_$Zeit_Datenholen
if [ ! -d "$Order_Erg" ]; then mkdir $Ordner_Erg; fi
if [ ! -d "$Ordner_Erg"/Error ]; then mkdir "$Ordner_Erg"/Error; fi
if [ ! -d "$Ordner_Erg"/Err_K ]; then mkdir "$Ordner_Erg"/Err_K; fi
if [ ! -d "$Ordner_Erg"/Stat-verteilung ]; then mkdir "$Ordner_Erg"/Stat-verteilung; fi
#mkdir $Ordner_Eingangsdateien

#Ordner_Erg=/media/x18914/DAPACLIP/DATEN/ERGEBNISDATEIEN/

# Für jedes gewuenschte Datum die Daten aus der Datenbank holen, interpolieren und die Ergebnisse wegschreiben
#--------------------------------------------------------------------------------------------------------------
while [ $Datum != $Datum_ende ]
do
	echo "$Datum"
	echo "-----------"
	
	# Daten aus der Datenbank holen und Datei mit Monats- und Tageswerten erzeuen
	#----------------------------------------------------------------------------
	#daten_holen
	
	
	# Tageswerte interpolieren
	#---------------------------
	interpolieren
	
	# Nächstes Datum erzeugen
	#-------------------------
	(( z ++ ))		# Zähler um eins hoeher setzen

	# Jahreswechsel Prüfen
	#----------------------
	if [ $m == 12 ] && [ $t == 31 ]
	then
		m=1
		t=1
		(( Jahr ++ ))
		
	# Monatswechsel prüfen
	#---------------------
	elif [ $t == 31 ]
	then
		t=1
		(( m ++ ))
	else
		(( t ++ )) 
	fi


	Tag=${Tage[t]}
	Monat=${Monate[m]}
	Datum="$Jahr$Monat$Tag"
	
	if [ $z -gt 55000 ]
	then
		echo "Skriptabbruch nach 55000 Schleifen-Durchlaeufen!"
		echo "Bitte kontrollieren ob das angegebene Datum passt und ggf. den Schleifenabbruch anpassen!"
		exit 1
	fi
	
done


#Daten holen und interpolieren auch für den letzten gesuchten Tag
	echo "$Datum_ende"
	# Daten aus der Datenbank holen und Datei mit Monats- und Tageswerten erzeuen
	#----------------------------------------------------------------------------
	#daten_holen
	
	# Tageswerte interpolieren
	#---------------------------
	interpolieren
	



#------------------------------------------------------------------------------------------------------------------------------------------

# Aufraeumen:
#--------------
#rm -r $Ordner_Eingangsdateien
#rm MIRAKEL-DATEN-HOLEN/STATION_DATA/*
#mv KRIGING/Ergebnisdateien/* $Ordner_Erg


echo
echo "End of controller script for interpolation"
echo

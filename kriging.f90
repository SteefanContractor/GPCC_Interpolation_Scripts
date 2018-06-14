      PROGRAM    KRIGING


!*     KRIGING OF RAIN GAUGE DATA FROM SYNOPTIC STATIONS
!*     -------------------------------------------------
!*     Subroutines:   GITTER, SEL_STATIONS, OPTINT, INOUT, STATIS, ASUB, ATSUB
!*                    SORT2, GAUSS, OUT_GRD, OUT_ARC
!*     Functions:     IA, ACLP
!*     Control files: Dates.txt, LAM_5.0_DEG, PHI_5.0_DEG, SEA_5.0_DEG
!*                               LAM_1.0_DEG, PHI_1.0_DEG, SEA_1.0_DEG
!*                               LAM_0.5_DEG, PHI_0.5_DEG, SEA_0.5_DEG
!*                               LAM_1.0_CUT, PHI_1.0_CUT, SEA_1.0_CUT
!*     Input files:   dates.dat -- defines the parameters, method ... for interpolation
!*		      file with measurement (lon, lat, value_day, vlalue_month)
!*				
!*     Output files:  one file with precipitation-values per Grid (format 9.2) beginning with top-left corner of map to top right to bottom...
!*                    one file with error-information per Grid (format 9.2)  beginning with top-left to top right to bottom...
!*
!*     F. Rubel, 18.05.1998 Version used for PIDCAP Ground Truth Precipitation Atlas
!*               23.06.1999 Adaption for application at GPCC, final version
!*               10.08.1999 Adaption for NASA precipitation verification
!*               25.10.1999 Missing grid point values are marked by 999.0
!*               01.11.1999 Alternatively ACFs for daily BALTEX data are available
!*               04.11.1999 Gridded Values lower than 0.01 mm are set to zero, not implemented!!
!*               09.03.2001 Output for SURFER
!*               12.03.2001 Output for ARCVIEW
!*     T. Fuchs  14.03.2001 Update of Output for SURFER (Output-data are log2 of the original data!!!)
!*               14.03.2001 Update of Output for ARCVIEW
!*               14.03.2001 Names of the Output-files are written in small letters. ARCVIEW is not able to process filenames with
!*                          capital letters.
!*               02.02.2002 Set treshold for unrealistic precip data to 250 mm.
!*     P.Otto    14.06.2004 Migration rus2 ==> rus4 :
!*                          - "WRITE (*," in  "WRITE (6," has been changed
!*                          - "READ(PREC,"(I5)") II" changed to "READ(PREC,"(I4)") II"
!*     P.Otto    17.11.2005 Adaption for global fields
!*     F. Rubel  17.11.2005 One constant ACF for global application, SWERT=500, MAX_STA=24, RAD_DEF=400
!*                          Extended parameterlist of OUT_GRD, SEL_BRIDGE replaced by SEL_STATIONS
!*                          Calculation only for GPCC defined land grid points
!*     P.Otto    12.12.2005 PAUSE-Anweisungen auskommentiert
!*     M. Ziese  ZZ.05.2011 increase station array 'S' for global calculationfrom 10000 to 80000 (ready for full data reanalysis)
!*			   change missing value from '999' to '-9', also initailisation of precipitation field
!*			   all calculated precipitation values above 0 mm were used (old version above 0.5 mm)
!*			   uses 4 till 15 stations as input for interpolation; increases search radius if necessary (old version at least one station for interpolation,
!*				search radius fixed, missing value in grid cell if no station data)
!*	        ZZ.12.2011 uses 4 till 10 stations as input for interpolation, like SPHEREMAP; increases search radius if necessary
!*
!*
!*               Attention: The current default selections are: Global Analyses
!*                          on 1 degree grids based on corrected data, Output is adapted for SURFER
!*
!*    
!*     K. Schamm XX.XX.2012 - possibility to interpolate precipitation values or precipitation in % of the monthly totals (has to be defined within the dates.dat file)
!*  			    - possibility to interpolate to a defined grid or else to the location of stations for cross-validation (for each station the data ist left out
!*				and precipitation is calulated for this location ) (has to be defined within the dates.dat file)
!*			    - Error Calculation for grid-interpolation: Calcualtion of the "standard deviation" (Yamamoto, 2000) depending on the precipitation values and the weights as used for
!*				calculated kriging-error (% of the variance) --> Total error is the product of both
!*			    - cleaned up not used functions ( such as output for surfer, for Arcview...)
!*			    - Length of names of Data-files is arbitrary, names are set in the dates.dat file
!*			    - parameter 'S' of station array, is "removed" / now allocatable (depending on the number of measurements)
!*			    - Most parameters for interpolation are now set within the dates.dat file
!*
!*
!*
!*     Type of ACF used:  KORR=EXP(-A*DISTANZ**B)







IMPLICIT NONE

! Grundeinstellungen (Teils aus Ini-Datei)
	CHARACTER(5)				:: KRIG						! Ist die Auswahl für Block- oder Pointkriging
	REAL					:: RAD_DEF					! Suchradius, entweder ein fester Wert oder variabel je nach Stationsdichte
	REAL					:: SWERT					! Schwellwert für unrealistisch hohe Messwerte
	REAL					:: FAKTOR					! Conversion faktor mm/h to W/m2 (not used)
	REAL					:: A, B						! Parameter für die AC-Funktion
	REAL					:: THRESHOLD					! Schwellwert für (?)
	REAL					:: OBSERR					! Observation-Error; Fester Parametwer für die Autokorrelationsfunktion (ACF)
	INTEGER					:: MAX_STA					! Maximale Anzahl an Stationen die für die Interpolation verwendet werden
	INTEGER					:: ANZ_MIN					! Mindeste Anzahl an Stationen die für die Interpolation verwendet werden
	Character(3)				:: abs_rel					! Gibt an ob Absolut- oder Relativwerte interpoliert werden
	Character(6)				:: interp_meth  				! = "Messpk" oder "Gitter"
	CHARACTER(8)				:: Datum					! Datum für das Interpoliert wird; aus Ini-Datei
	Character(1)				:: Rad_Variabel					! Gibt an ob der Suchradius fest oder in abhängigkeit von Stationsdichte ist
	CHARACTER(500)				:: DATEI					! Dateiname der Datei mit den Messwerten (?)

! Raseter:
	INTEGER					:: N,M						! Anzahl an Rasterpunkten in lon und lat Richtung
	REAL, dimension(:,:), allocatable	:: LAM,PHI,SEA					! Koordinaten und Landseemaske auf dem Gitter
	REAL, dimension(:,:), allocatable	:: LAMrot,PHIrot				! Koordinaten auf dem rotierten Gitter wenn fuer 0.22 Grad gerechnet wird
	REAL, dimension(:,:), allocatable	:: NS, E, Err_var				! Interpolierter Niederschlagswert, Kriging-Fehler und Gesamtfehler in [mm] auf dem Raster
	INTEGER					:: I1,J1,A_X1,A_X2,A_Y1,A_Y2			! X-coordinates of the section, Y-coordinates of the section
	INTEGER					:: A_N,A_M					! Dimension of a section of the model domain

! Messwerte:	
	REAL, DIMENSION(:), Allocatable		:: LAM_SYN,PHI_SYN,NS_SYN, NS_SYN_kopie		! Koordinaten und Messwerte der Messstationen
	INTEGER					:: MAX_SYN					! Count of synoptic stations
	INTEGER					:: MAX_NS					! Count of stations with precipitation > Spuren
	INTEGER					:: MAX_ELI					! Count of eliminated stations
	INTEGER, DIMENSION(:), Allocatable 	:: NR_SYN					! Stations-ID
	INTEGER					:: Anz_Mess, MM 				! Anzahl Messwerte, Anzahl Messwerte + 1
	INTEGER, DIMENSION(:,:), Allocatable	:: Anz_Stat_in_Box				! Anzahl Stationen je Raster

! Zusatzinfos für Ergebnisdatei
	CHARACTER(500)				:: Datei_aus					! Name der Ergebnisdatei (wird in ini-Datei angegeben
	INTEGER, dimension(:), allocatable	:: Mess_verw					! Anzahl der Stationen die für die Interpolation je Raster verwendet wurden
	REAL, DIMENSION(:), Allocatable		:: Rad_verw					! Der letztendlich je Raster verwendete Suchradius
	REAL,DIMENSION(:), Allocatable		:: A_Verw, B_Verw, C_verw			! Parameter der ACF die je Raster verwendet wurden

! Für Monatswerte bzw. Relativwerte:
	Character(500)				:: Datei_MW
	REAL, DIMENSION(:), Allocatable		:: LAM_MW,PHI_MW,NS_MW
	INTEGER, DIMENSION(:), Allocatable	:: ID_MW
	REAL					:: Anz_MW, Norm_MW				! Anzahl Messwerte fuer MW-Interpolation und Normals der MW-Interp aus der MW-Datei
	REAL					:: MW_gesucht
	
! Diverses
	INTEGER					:: I,J,K					! Laufvariablen
	real					:: pii						! PI !!! = 3,14159265;  = 4.*atan(1.)
	REAL, DIMENSION(:), Allocatable		:: Err_rel 					!
	REAL, Dimension(:,:), Allocatable	:: Err_abh_Sta					!
	INTEGER					:: x						! Anzahl Zeichen von Datei_MW
	REAL					:: NS_int_rel_Diff, NS_int_rel			!
	INTEGER					:: z_Dat_aus  					! Anzahl Zeichen von Datei_aus
	integer :: ka    ! Schleifenvariable


	

!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
!
!		PROGRAMMSTART!		PROGRAMMSTART!		PROGRAMMSTART!		PROGRAMMSTART!		PROGRAMMSTART!		PROGRAMMSTART
!
!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~




!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
! Variablen Definieren, Einzulesende Datei festlegen


	KRIG='BLOCK'  ! kann auch raus
	SWERT=10000	
	FAKTOR=1.0
	THRESHOLD=0.15
	Rad_variabel='j'
!	A=0.014
!	B=0.726
!	ANZ_MIN = 4
!	MAX_STA=10  !24	
!	OBSERR = 1 - OBSERR
	OBSERR = 0.05
	pii = 4.*atan(1.)

! Einzulesende Datei mit Messwerten und Parameter zur Interpolation
	OPEN(1,FILE="dates.txt")
		READ(1,*) DATEI
		READ(1,*) DATUM
		READ(1,*) RAD_DEF
		Read(1,*) A
		Read(1,*) B
		Read(1,*) abs_rel
		Read(1,*) interp_meth
		Read(1,*) ANZ_MIN
		Read(1,*) MAX_STA
		Read(1,*) Datei_aus
		Read(1,*) Datei_MW		
		Read(1,*) N
		Read(1,*) M		
	CLOSE(1)
	z_Dat_aus=index(Datei_aus, ' ') 



! Suchradius nach Shepard (1968) wie in Spheremap (In Abhängigkeit der Stationsdichte
	call zaehl_Mess(DATEI, Anz_Mess)
	RAD_DEF = sqrt(28./real(Anz_Mess))*6378.
	
	
! Kontrollausgabe zu den Einstellungen	
	write(6,*) 
	write(6,*) 'Einstellungen fuer die Interpolation:'	
	write(6,*) '-------------------------------------'
	write(6,*) 
	write(6,'(A53, F6.2)') ' Verwendeter Suchradius in km:                       ', Rad_DEF
	write(6,'(A53, F6.4, x, F6.4)') ' ACF A und B sind:                                   ', A, B
	WRITE(6,'(A53, A2, A1, A2, A1, A4)') ' Datum:                                              ' &
		&, DATUM(7:8), '.', DATUM(5:6), '.',DATUM(1:4)
	WRITE(6,'(A53, A3,A11,A6,A14 )') ' Interpolationsmethode:                              ', &
		& abs_rel, '-Werte auf ', interp_meth ,' interpoliert.'
	WRITE(6,'(A53, I2 )') ' Mindestens verwendete Stationen fuer Interpolation: ', Anz_Min 
	WRITE(6,'(A53, I2 )') ' Maximal verwendete Stationen fuer Interpolation:    ', MAX_Sta
	WRITE(6,'(A53, I3 )') ' Anzahl der Gitterpunkte in x-Richtung:              ', N
	WRITE(6,'(A53, I3 )') ' Anzahl der Gitterpunkte in y-Richtung:              ', M	
	WRITE(6,*) 
	WRITE(6,*) 'Ergebnisdatei: ', Datei_aus(1:(z_Dat_aus-1))
	write(6,*) 
	write(6,*)
	write(6,*)
	write(6,*) 'Start:' 
	write(6,*) '-------'

	
!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****

	
	
	allocate ( LAM_SYN(Anz_Mess), PHI_SYN(Anz_Mess), NS_SYN(Anz_Mess), NR_SYN(Anz_Mess), NS_SYN_kopie(Anz_Mess))
	allocate ( LAM_MW(Anz_Mess), PHI_MW(Anz_Mess), NS_MW(Anz_Mess), ID_MW(Anz_Mess))	
	allocate ( Err_rel(Anz_Mess), Err_abh_Sta(Anz_Mess, 11), Mess_verw(Anz_Mess), Rad_verw(Anz_Mess) )


!*     Determination of section of model domain (not used)
!*     ---------------------------------------------------
	If (interp_meth == "Messpk") Then
		M = 1
		N = Anz_Mess
!	Else If (interp_meth == "Gitter") Then			! Hier muss was geändert werden für flexible Raster ************************************!!! # # ! ! ! ! ! ! ! !
!		N = 212 !360		!212					! aus INI-Datei einlesen??
!		M = 206 !180		!206
	End If
	A_X1= 1
	A_X2= N
	A_Y1= 1
	A_Y2= M
	A_N=A_X2-A_X1+1
	A_M=A_Y2-A_Y1+1

		
	allocate  (LAM(N,M),PHI(N,M),SEA(N,M),NS(N,M),E(N,M), Err_var(N,M) )
	allocate  (LAMrot(N,M),PHIrot(N,M) )
	allocate  (Anz_Stat_in_Box(N, M))	





!**************************************************************************************************************************************************
!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~***
!**************************************************************************************************************************************************
! Interpolation Starten



	! Fuer Kriging auf ein Raster (nicht auf Messstationen)
	If (interp_meth == "Gitter") Then
		!*     Read grid coordinates
		write(6,*) 'Subroutine Gitter wird aufgerufen'
		CALL GITTER(N,M,LAM,PHI,SEA) !,LAM_ALL,PHI_ALL,SEA_ALL)
	End If

	! Stationen und Messwerte einlesen
	write(6,*)
	write(6,*) 'Stationen und Messwerte werden eingelesen:'
	CALL SEL_STATIONS(DATEI,Anz_Mess,LAM_SYN,PHI_SYN,NS_SYN,NR_SYN,MAX_SYN,MAX_NS,MAX_ELI,SWERT, abs_rel, NS_MW)
	allocate ( A_Verw(MAX_SYN), B_Verw(MAX_SYN), C_verw(MAX_SYN) )

	
	IF (MAX_SYN == 0) THEN
		WRITE (6,*) 'Data not available'
	ELSE
	MM = Max_SYN + 1	! Anzahl an Stationen mit "gueltigen" Niederschlagswerten ( + 1 )
	
	NS_SYN_kopie=NS_SYN





! ***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~
! ~~~***~~~***			Interpolation auf Messpunkte -- Es wird eine Datei mit Differenzen erzeugt          ~~~***~~~***~~~***~~~***~~~***
! ***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~
	

	
			
! ***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~
! ~~~***~~~*** 				"Normales" Kriging auf Gitterpunkte 					    ~~~***~~~***~~~***~~~***~~~***
! ***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~

		If (interp_meth == "Gitter") Then
			! Interpolation Starten


			write(6,*) 
			write(6,*) 'Interpolation auf Gitter (Subroutine Optint) wird jetzt gestartet'

			CALL OPTINT(N,M,LAM,PHI,NS,E,A,B,Anz_Mess,KRIG,OBSERR, PHI_SYN,LAM_SYN,NS_SYN,MAX_SYN,MAX_STA, RAD_DEF,SEA, &
					& A_X1,A_X2,A_Y1,A_Y2,MM, ANZ_MIN, abs_rel, Rad_Variabel, Datum, Err_var)

			call lage_Mess (Phi_SYN, Lam_SYN, Phi, Lam, NS_SYN, M, N, MAX_SYN, SEA, Anz_Stat_in_Box)	! Zählt die Anzahl an Stationen im Raster

			!--------------------------------------------------------------------------------------------------------------------
			! FÜR RELATIVWERTE AUF GITTER
			! Ergebnisdatei erzeugen:
						
			If (abs_rel == 'rel') then
			! wenn auf 0.22Grad-Gitter interpoliert wird eine andere MW-Datei verwenden mit 0.25 oder 0.22 Grad, dann je Raster aus der MW-Datei den
			! nächstgelegenen Punkt raussuchen und damit den absolutwert berechnen	
			
			if ( n == 360 .OR. n == 720 .OR. n == 144 ) then
			!-----------------------------------
			! Wenn auf das 1Grad-Gitter interpoliert wird:
			
				x=index(Datei_MW, ' ')
				write (6,*) 'Datei mit Monatswerten ist: ', Datei_MW
					open (unit = 246, File = Datei_MW )
! Header ueberlesen
do ka = 1,14
  read(246,*)
enddo
					
					open(1000, file = Datei_aus)	!Interpolationsergebnisse in Datei schreiben zur Darstellung mit GrADS
					open(2000, file = 'OUT/Error/'//Datum//'.dat')	!Interpolationsfehler in Datei schreiben zur Darstellung mit GrADS					
					open(3000, file = 'OUT/Err_K/'//Datum//'.dat')	!Interpolationsfehler in Datei schreiben zur Darstellung mit GrADS
					open(4000, file = 'OUT/Stat-verteilung/'//Datum//'.dat')	!Stationsverteilung in Datei schreiben 										
						do I = 1,M
							do J = 1,N
								read (246,*) NS_MW(1)
								
								if ( (NS_MW(1) < 0) .or. NS(J, M- I +1) < -2) then    ! Fehlkennung des Monatswertes als auch des Tageswertes muss geprueft werden, da Land-See-Masken verschieden sein koennen
									NS(J, M- I +1) = -99999.99
									Err_var(J, M-I +1) =  -99999.99
									E(J, M-I +1) =  -99999.99
								else
									if ( (NS(J, M- I +1) < 0) ) NS(J, M- I +1) = 0
									if (NS(J, M- I +1) > 1) NS(J, M- I +1) = 1 ! TW Sollte nicht größer als der MW sein!
									NS(J, M- I +1) = NS(J, M- I +1) * NS_MW(1)
									
									if ( (Err_var(J, M-I +1) < -99 ) ) then
								  		Err_var(J, M-I +1) =  -99999.99
										E(J, M-I +1) =  -99999.99
									else if ( (Err_var(J, M-I +1) < 0 ) ) then
										Err_var(J, M-I +1) = 0
									else
										Err_var(J, M-I +1) = Err_var(J, M-I +1) * NS_MW(1)
									end if
								end if
								
!								if ( E(J, M-I +1) >= 0 ) then
!								E(J, M-I +1) = ( E(J, M-I +1) / 100.0 ) * Err_var(J, M-I +1) +	Err_var(J, M-I +1)	!!!!!*******!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!								else
!								E(J, M-I +1) =  -99999.99
!								end if
								write(1000,'(F7.2, 1x, F7.2, 2x, F9.2)') LAM(J, M- I +1)*360/(2*pii), &
									& PHI(J, M- I +1)*360/(2*pii), NS(J, M-I +1)
								write(2000,'(F7.2, 1x, F7.2, 2x, F9.2)') LAM(J, M- I +1)*360/(2*pii), &
									& PHI(J, M- I +1)*360/(2*pii), Err_var(J, M-I +1) 
								write(3000,'(F7.2, 1x, F7.2, 2x, F9.2)') LAM(J, M- I +1)*360/(2*pii), &
									& PHI(J, M- I +1)*360/(2*pii), E(J, M-I +1)
								write(4000,'(F7.2, 1x, F7.2, 2x, I9)') LAM(J, M- I +1)*360/(2*pii), &
									& PHI(J, M- I +1)*360/(2*pii), Anz_Stat_in_Box(J, M-I +1) 
	
							enddo
						enddo
					close(1000)
					close(2000)
					close(3000)
					close(4000)		
					close (unit = 246)



			!-----------------------------------
			! Wenn auf das rotierte 0.22-Grad-Gitter interpoliert wird:
			else if ( n == 212 ) then
			
				deallocate ( NS_MW, LAM_MW,PHI_MW )
				allocate ( NS_MW(259200), LAM_MW(259200), PHI_MW(259200) )
				x=index(Datei_MW, ' ')
				write (6,*) 'Datei mit Monatswerten ist: ', Datei_MW
					open (unit = 246, File = Datei_MW )
					open (unit = 88, file = 'test-Koord.dat' )
						Lam_MW(1) = -180
						PHI_MW(1) = 90
						Do I = 1,259200
							read (246,*) NS_MW(I)
							if ( i > 1 ) Lam_MW(I) = LAM_MW(I-1) + 0.5	! -180 bis 180
							if ( i > 1 ) PHI_MW(I) = PHI_MW(I-1) 		! 90 bis -90
							if ( Lam_MW(I) == 180 ) then
								Lam_MW(I) = -180
								PHI_MW(I) = PHI_MW(I) - 0.5
							end if
						End Do
					close (unit = 246)
					close (unit = 88)
					
					
					! LAM und PHI mit den "normalen" Korrdinaten (nicht rotiert) belegen für Suche des passenden MW-Rasters
					DATEI='LAT_2.2DEG'
					WRITE (6,*) 'Read '//DATEI
					CALL INOUT (LAM,N,M,1,DATEI)
					DATEI='LON_2.2DEG'
					WRITE (6,*) 'Read '//DATEI
					CALL INOUT (PHI,N,M,1,DATEI)

					! LAM und PHI mit den "rotierten" Korrdinaten belegen für Ergebnisdatei
					DATEI='LAT_2.2D_R'
					WRITE (6,*) 'Read '//DATEI
					CALL INOUT (LAMrot,N,M,1,DATEI)
					DATEI='LON_2.2D_R'
					WRITE (6,*) 'Read '//DATEI
					CALL INOUT (PHIrot,N,M,1,DATEI)
					
					open(1000, file = Datei_aus)	!Interpolationsergebnisse in Datei schreiben zur Darstellung mit GrADS
					open(2000, file = 'Error.dat')	!Interpolationsfehler in Datei schreiben zur Darstellung mit GrADS										
						do I = 1,M
							do J = 1,N
								do K = 1, 259200
									X=1
									If ( ( LAM_MW(K)       ) <= (LAM(J, M- I +1)) ) then
									If ( ( LAM_MW(K) + 0.5 ) > (LAM(J, M- I +1)) ) then
									If ( ( PHI_MW(K)       ) >= (PHI(J, M- I +1)) ) then
									If ( ( PHI_MW(K) - 0.5 ) < (PHI(J, M- I +1)) ) then
										MW_gesucht = NS_MW(K)
										X=0
										exit
									end if
									end if
									end if
									end if
									
									
								end do
								
								if ( X == 1 ) then
									write(6,*) PHI(J, M- I +1), LAM(J, M- I +1)
									write(6,*) 'Kein Monatswert gefunden; pruefen was schief laueft'
									stop
								else

								end if

								
								if ( (MW_gesucht < 0)) then
									NS(J, M- I +1) = -99999.99
								else
									if ( (NS(J, M- I +1) < 0) ) NS(J, M- I +1) = 0
									if (NS(J, M- I +1) > 1) NS(J, M- I +1) = 1 ! TW Sollte nicht größer als der MW sein!
									NS(J, M- I +1) = NS(J, M- I +1) * MW_gesucht
									
									if ( (Err_var(J, M-I +1) < -99 ) ) then
								  		Err_var(J, M-I +1) =  -99999.99
									else if ( (Err_var(J, M-I +1) < 0 ) ) then
										Err_var(J, M-I +1) = 0
									else
										Err_var(J, M-I +1) = Err_var(J, M-I +1) * MW_gesucht
									end if
								end if
								write(1000,'(F9.2)') NS(J, M-I +1)
								write(2000,'(F9.2)') Err_var(J, M-I +1)
									
	
							enddo
						enddo
					close(1000)
					close(2000)
					
						
			end if
			


			!--------------------------------------------------------------------------------------------------------------------
			! FÜR ABSOLUTWERTE AUF GITTER
			! Ergebnisdatei erzeugen:
			
			else if ( abs_rel == 'abs') Then
				open(1000, file = Datei_aus)
				open(2000, file = 'Error.dat')	
					do I = 1,M
						do J = 1,N
							if(NS(J, M- I +1) < 0) NS(J, M- I +1) = -99999.99
!							write(1000,'(F9.2)') NS(J, M-I +1)
                                                        write(1000,'(F7.2, 1x, F7.2, 2x, F9.2)') LAM(J, M- I +1)*360/(2*pii), &
									& PHI(J, M- I +1)*360/(2*pii), NS(J, M-I +1)
!							write(2000,'(F9.2)') Err_var(J, M-I +1)
                                                        write(2000,'(F7.2, 1x, F7.2, 2x, F9.2)') LAM(J, M- I +1)*360/(2*pii), &
									& PHI(J, M- I +1)*360/(2*pii), Err_var(J, M-I +1)
						enddo
					enddo
				close(1000)
				close(2000)
			end if
			

! ***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~***~~~
		End If


	ENDIF

	WRITE (6,*) 'End of program'
End


!*************************************************************************************************************************************
!*#####################################################################################################################################


include 'Subroutinen_FGD/function-Variogramm.f90'	! Ist die Variogrammfunktion; benoetigt ACF-Parameter und wird in optint aufgerufen
include 'Subroutinen_FGD/subroutine-aclp.f90'		! Funktion zur Berechnung des Abstands
include 'Subroutinen_FGD/subroutine-gauss.f90'		! Wird von Optint aufgerufen -- zur Berechnung der Interpolationsgewichte
include 'Subroutinen_FGD/subroutine-gitter.f90'		! Zum Einlesen von Gitterkoordinaten und Land_See Anteil
include 'Subroutinen_FGD/subroutine-ia.f90'		!
include 'Subroutinen_FGD/subroutine-inout.f90'		! Wird von Subroutine-gitter.f90 benötigt
include 'Subroutinen_FGD/subroutine-optint.f90'		! Fuer Interpolation auf Gitterpunkte
include 'Subroutinen_FGD/subroutine-sel-stations.f90'	! Zum Einlesen der Messwerte aus Datei nur für Monatswerte!!!
include 'Subroutinen_FGD/subroutine-sort2.f90'		!
include 'Subroutinen_FGD/subroutine-statis.f90'		!
include 'Subroutinen_FGD/subroutine-zaehl_Mess.f90'	! Zum Zählen der Zeilen in einer Datei (zählen der Anzahl an Messstationen)
include 'Subroutinen/subroutine-lage_Mess.f90'		! Zum Zählen der Anzahl an Stationen je Raster

      SUBROUTINE SEL_STATIONS(DATEI,S,LAM_SYN,PHI_SYN,NS_SYN,NR_SYN,MAX_SYN,MAX_NS,MAX_ELI,SWERT, abs_rel, NS_MW)
!*       Reading of synoptic precipitation values from GPCC file format
!*
!*       F. Rubel, 17.11.2005 global data

	IMPLICIT NONE

	CHARACTER(100)			:: D
	CHARACTER(500) 			:: DATEI
        INTEGER 			:: S,I,J,I1,MAX_SYN,MAX_NS,MAX_ELI
        REAL 				:: LAM,PHI,NS,SWERT
        REAL 				:: LAM_SYN(S),PHI_SYN(S),NS_SYN(S),NS_NEU, NS_MW(S)
        CHARACTER(12) 			:: NR
        INTEGER 			:: NR_SYN(S)
        CHARACTER(15) 			:: NA
        CHARACTER(10) 			:: PREC
	REAL				:: PREC_MW
!        CHARACTER(1) 			:: CORRECTION
	INTEGER 			:: x, io_error
	CHARACTER(3)			:: abs_rel
	INTEGER				:: Q

!------------------------------------------------------------------------------   
!------------------------------------------------------------------------------


	x = index(Datei,' ')
        OPEN (1,FILE=DATEI(1:(x-1)))


1       FORMAT (A12,A15,2I10,A5,A7)
101     FORMAT (A12,A15,2I10,A103,A5)
102	format (F7.2, 1x, F7.2, 1x, A7)


!103	format (A9, F8.2, F8.2, A10)
104	format ( F9.4,F10.4, A7, F7.1) !( 2F10.2, A10, F10.2) -S Contractor
2       FORMAT (1F8.6,2F8.2)


!*       Initial values
        PHI_SYN(1)=0
        LAM_SYN(1)=0

        I=0
        MAX_NS=0
        MAX_ELI=0
	Q = 0		! Laufindex fuer Kontrollausgabe

	write(6,*) ' LAM        PHI        NS     '
	write(6,*) '------------------------------'



3       CONTINUE


		READ (1,104,END=5,ERR=3) PHI,LAM, PREC, PREC_MW

		! Pruefen:
		IF ( PREC_MW == -1000 ) GOTO 3 ! skip missing monthly value S Contractor
		IF ( PREC == "-999." )  GOTO 3					!* Missing value
		IF ( (LAM <= -999999) .OR. ((PHI <= -999999)) ) GOTO 3		!* Coordinates in degree

		IF (PREC.EQ."SPUR") THEN					!* Spuren: values above 0.05 mm are transmitted as 0.1 mm
			NS=0.04
			GOTO 9
		ENDIF
		
		IF (Q <= 10) then	!*       Control output
			Q = Q + 1
	        	WRITE(6,"(3F10.3)") LAM_SYN(I),PHI_SYN(I),NS_SYN(I)
		End If
	
		

!*         Ordinary values
!*         ---------------
	If (abs_rel =='abs') then
		READ(PREC,"(F7.1)") NS 
	else if (abs_rel == 'rel') then
		Read(PREC,"(F7.1)") NS
		if ( PREC_MW == 0 ) then
			NS = 0.0
		else
			NS = NS / PREC_MW
		end if
!!		write(6,'(F10.4, A10)') NS, PREC
!!		write(6,*) '++++++++++++++++++++++++++++++++'
	end if
	
	IF ( NS < 0. )  GOTO 3	!* Missing value
	IF (NS >= SWERT) THEN		!* Values above threshold are eliminated  Will ich eigentlich nicht
		WRITE (2,*) 'Above threshold ',PHI,LAM,NS
		MAX_ELI=MAX_ELI+1
		GOTO 12
	ENDIF

!*         Interstation distance equal to zero
!*         -----------------------------------
!*         The linear equation system is not solvable for zero interstation distances.
!*         For that reason observations at the same location are averaged.
9         CONTINUE
          IF (I == 0) GOTO 11
!*         GOTO 11
	DO J = 1, I
		IF (ABS(LAM-LAM_SYN(J)) < (0.01)) THEN       ! below 1 km
			IF (ABS(PHI-PHI_SYN(J)) < (0.01)) THEN     ! below 1 km

!*               Searching for unrealistic values
				IF (ABS(NS-NS_SYN(J)) >= 90) THEN
					IF (NS > NS_SYN(J)) THEN
						NS_NEU = NS_SYN(J)
						MAX_ELI = MAX_ELI+1
					ELSE
						NS_NEU=NS
						MAX_ELI=MAX_ELI+1
					ENDIF
				ELSE
					NS_NEU=(NS+NS_SYN(J))/2 	! Averaging of observations at the same location, e.g. identical measurements

				ENDIF
				NS_SYN(J)=NS_NEU
				GOTO 12
			ENDIF
		ENDIF
	End DO

11        I=I+1
          LAM_SYN(I)=LAM
          PHI_SYN(I)=PHI
          NS_SYN(I) =NS
	  NS_MW(I)=PREC_MW
!	  READ(NR,'(I9)') NR_SYN(I)	  
!          NR_SYN(I) =NR
          IF (NS > 0) THEN
            MAX_NS=MAX_NS+1
          ENDIF

12      GOTO 3
5       CLOSE (1)






        MAX_SYN=I
	IF (MAX_SYN == 0) THEN
		WRITE (6,*) 'Data not available'
		Stop
	end if

!	write(6,*) ' LAM        PHI        NS     '
!	write(6,*) '------------------------------'
!	DO I=1,10	!*       Control output
!	         WRITE(6,"(3F10.3)") LAM_SYN(I),PHI_SYN(I),NS_SYN(I)
!	End do


      RETURN
      END

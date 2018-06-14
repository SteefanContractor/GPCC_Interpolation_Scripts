SUBROUTINE OPTINTpkt(N,M,LAM,PHI,F_O,E,A,B,S,KRIG,OBSERR,PHI_SYN,LAM_SYN,NS_SYN,MAX_SYN, &
			& MAX_STA,RAD_DEF,A_SEA,A_X1,A_X2,A_Y1,A_Y2, MM, ANZ_MIN, Mess_verw, abs_rel, &
			& Rad_verw, A_verwV, B_verwV, C_verwV, Datum_C, &
			& Err_var)

!*       Optimum Interpolation without background field (kriging)
!*
!*
!*       F. Rubel, 08.02.1994
!*                 18.05.1999 Final version for GPCC
!*
!*       Reference: Gandin, L. S., 1963: Objective Analysis of Meteorological Fields.
!*                    (Gidrometeor. Izdat., Leningrad. [Israel Program for Scientific
!*                    Translation, Jerusalem 1965, 242pp.
!*                  Gandin, L. S., 1993: Optimal Averaging of Meteorological Fields.
!*                    National Meteorological Center, Office Note 397, 68pp.


	IMPLICIT NONE

	CHARACTER(5)			:: KRIG
	INTEGER				:: S,P,MAX_SYN,ANZ_STA,ANZ_NEU,MAX_STA, ANZ_MIN
	INTEGER				:: I,I1,I2,J,K,KK,q, L,O
	INTEGER				:: N,M,MM,A_X1,A_X2,A_Y1,A_Y2
	REAL				:: LAM(N,M),PHI(N,M),F_O(N,M),E(N,M)
	REAL				:: LAM_SYN(S),PHI_SYN(S),NS_SYN(S),A_SEA(N,M)
	REAL				:: A,B,RAD_DEF,RAD,OBSERR
	CHARACTER(3)			:: abs_rel
	

!	PARAMETER (MM=500)
	REAL				:: F_I(MM),D_I(MM),MUE_OI(MM),MUE_IJ(MM,MM),P_J(MM),MUE_00
	REAL				:: D_L1,D_P1,MUE_1,MUE_2,MUE_3,MUE_4
	REAL				:: LAM_I(MM),PHI_I(MM)
	REAL				:: Err_var(N,M)	

!*       DUMMYs for 'GAUSS'
	REAL				:: D1(MM)
	INTEGER				:: D2(MM)
	REAL				:: D,R,P1,P2,L1,L2
	REAL				:: PI,ACLP
	INTEGER				:: Anz_inRad
	REAL				:: Rad_X
	INTEGER				:: Mess_verw(N)
	REAL				:: Rad_verw(N)
	REAL				:: Variogramm
	
	Character(1)			:: Region
	Character(1)			:: Klimazonen(64800)
	REAL				:: Lat_Kli(64800), Lon_Kli(64800)
	CHARACTER(1)			:: Vario_variabel
	Character(1)			:: KLimaz_Stat(S)

	REAL, DIMENSION(64800)		:: lon_vario, lat_vario, Anz_Vario, A_vario, B_Vario, C_Vario	
	REAL, DIMENSION(MAX_SYN)	:: A_verwV, B_verwV, C_verwV	
	INTEGER				:: variostat
	INTEGER				:: vario_anz_pkt(S)
	CHARACTER(8)			:: Datum_C
	Character(57) 			:: datei_vario_ein	 
	
	PI=3.141592654/180
	R=6379	!*       Radius of earth

	q = 0	! Anzahl der negativen Gewichte

	
	

!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~





!*       Initialization of precipitation fields
	DO I=1,N
		DO J=1,M
			F_O(I,J)=-9
			E(I,J)=0
		End Do
	End Do


	
!*       For all grid points
	DO I=1,N
		DO J=1,M
			LAM(I,J)=LAM(I,J)*PI
			PHI(I,J)=PHI(I,J)*PI
		End Do
	End DO



!*       For all stations
	DO I=1,MAX_SYN
		LAM_SYN(I)=LAM_SYN(I)*PI
		PHI_SYN(I)=PHI_SYN(I)*PI
	End Do


!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
	

!*       Calculation of MUE_00 for the interpolation error
	MUE_1=1.0

!*       Calculations for corner points of grid area
	I=INT((A_X2-A_X1)/2)
	J=INT((A_Y2-A_Y1)/2)
	D_L1=(LAM(I+1,J)-LAM(I,J))/2
	D_P1=(PHI(I,J+1)-PHI(I,J))/2

	L2=LAM(I,J)
	P2=PHI(I,J)
	L1=LAM(I,J)+D_L1
	P1=PHI(I,J)+D_P1
	D=R*ACOS(SIN(P1)*SIN(P2)+COS(P1)*COS(P2)*COS(L2-L1))
	MUE_2=Variogramm(OBSERR, A, B, D)

	L1=LAM(I+1,J)
	P1=PHI(I,J)
	D=R*ACOS(SIN(P1)*SIN(P2)+COS(P1)*COS(P2)*COS(L2-L1))
	MUE_3=Variogramm(OBSERR, A, B, D)

	L2=LAM(I,J)+D_L1
	P2=PHI(I,J)+D_P1
	L1=LAM(I,J)-D_L1
	P1=PHI(I,J)-D_P1
	D=R*ACOS(SIN(P1)*SIN(P2)+COS(P1)*COS(P2)*COS(L2-L1))
	MUE_4=Variogramm(OBSERR, A, B, D)

	MUE_00=(20*MUE_1+32*MUE_2+8*MUE_3+4*MUE_4)/64

!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
I = 1 	! Später I = 1, Anz_Mess
J = 1

!*       For all grid points
	DO I=1, MAX_SYN
		If ( mod(I,1000) == 0 ) WRITE (6,*) I, ' Punkte von ', MAX_SYN, ' bearbeitet'
	
			RAD=RAD_DEF	! Radius in Bogenmaß ?!? --> wird später mit Abstand * Radius_erde verglichen -- OK SO!
			A_verwV(I) = A
			B_verwV(I) = B
			C_verwV(I) = OBSERR
		

			
!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
! Searching for all stations within RAD_DEF

				KK=0

501			         CONTINUE
				F_O(I,J)=0
				K=0
				L1=LAM_SYN(I)  !Eigentlich Lam und PHI(I,J)
				P1=PHI_SYN(I)

				
			
				DO P=1,MAX_SYN
					L2=LAM_SYN(P)
					P2=PHI_SYN(P)
					D=R*ACLP(L1,P1,L2,P2)

					IF (D <= RAD) THEN
						IF ((L2 == L1).AND.(P1 == P2)) THEN
							F_I(I)=NS_SYN(I)
						Else
							K=K+1
							F_I(K)=NS_SYN(P)
							D_I(K)=D
							LAM_I(K)=L2
							PHI_I(K)=P2
						End If
					ENDIF
	
					! Quicker search for regions with high station density
					IF (K > MAX_STA*3) THEN
						RAD=RAD-RAD/3
						KK=1
						GOTO 501
					ENDIF
					Rad_verw(I) = RAD
				End Do
				ANZ_STA=K


			! If less than four stations within RAD_DEF, than maximal error
				If (ANZ_STA <= ANZ_MIN)then		!IF (ANZ_STA.EQ.0) THEN
					RAD=RAD*1.1	!F_O(I,J)=999.0
					goto 501	!E(I,J)=1.0
				ENDIF

			! Sorting with respect of D, only MAX_STA stations are considered
				IF (ANZ_STA  > MAX_STA) THEN
					CALL SORT2(MM,ANZ_STA,D_I,F_I,LAM_I,PHI_I)
					ANZ_STA=MAX_STA
					
				ENDIF
			

!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****

! Hier Testversion für neue Variogramme eingebaut:

!			IF (Anz_Sta >= 10) THEN 
!				call variogramm_erst (OBSERR, A,  B, LAM_I, Phi_I, F_I, Anz_Sta)
!				stop
!			end if

!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****


				Mess_verw(I) = 0


				IF (Anz_Sta >= ANZ_MIN) THEN 
					Mess_verw(I) = Anz_Sta
					DO I1=1,ANZ_STA
						MUE_OI(I1)=Variogramm(OBSERR, A, B, D_I(I1))

					End Do

					!* For Block-Kriging only
					IF (KRIG.EQ.'BLOCK') Then

!*           For Block-Kriging with numerical solution of the areal integral
	
						DO I1=1,ANZ_STA
							L2=LAM_I(I1)
							P2=PHI_I(I1)
	
							L1=LAM(I,J)
							P1=PHI(I,J)
							D=R*ACLP(L1,P1,L2,P2)
							MUE_1=Variogramm(OBSERR, A, B, D)

							MUE_OI(I1)=(4*MUE_OI(I1)+MUE_1)/5
						End Do
					End If
	
					DO I1=1,ANZ_STA-1
						DO I2=I1+1,ANZ_STA
							L1=LAM_I(I1)
							P1=PHI_I(I1)
							L2=LAM_I(I2)
							P2=PHI_I(I2)
							D=R*ACLP(L1,P1,L2,P2)

							IF (D == 0) THEN
								D=1.0
							ENDIF
							MUE_IJ(I1,I2)=Variogramm(OBSERR, A, B, D)

							MUE_IJ(I2,I1)=MUE_IJ(I1,I2)
						End DO
					End Do
	
	
					DO I1=1,ANZ_STA
						MUE_IJ(I1,I1)=1.0
					End Do
					ANZ_NEU=ANZ_STA+1
			
					DO I1=1,ANZ_NEU
						MUE_IJ(ANZ_NEU,I1)=1.0
						MUE_IJ(I1,ANZ_NEU)=1.0
					End Do
					MUE_IJ(ANZ_NEU,ANZ_NEU)=0.0
					MUE_OI(ANZ_NEU)=1.0

					
					CALL GAUSS(MM,ANZ_NEU,MUE_IJ,MUE_OI,D1,D2,P_J)
				
!~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~
!*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****~~~~~*****
!* Calculation of precipitation value

					DO I1=1,ANZ_STA
						IF (P_J(I1) < 0) THEN
							q = q+1
!							write(6,*) 'Gewichte sind Negativ', q
						End If
						F_O(I,J)=F_O(I,J)+P_J(I1)*F_I(I1)
					End Do

					! Set negative values to zero
					If (abs_rel == "rel") then
						IF (F_O(I,J) <= 0.0 ) F_O(I,J)=0
					Else If (abs_rel == "abs") then
						IF (F_O(I,J) <= 0.2 ) F_O(I,J)=0
					Else
						write(6,*) 'Es ist nicht angegeben ob relative oder alsoluter Werte berechnet werden; Programm wird abgebrochen'
						Stop
					End If
					
					
					
					!* Calculation of Error-information ("Varianz")
					DO I1=1,ANZ_STA	
						Err_var(I,J) = Err_var(I,J) + (P_J(I1) * ( F_I(I1) - F_O(I,J) )**2 )
					End Do
					if ( (Err_var(I,J) < 0 ) ) then
						Err_var(I,J) =  -99999.99
					else
						Err_var(I,J) = sqrt(Err_var(I,J) )
					end if


					! Calculation of interpolation error (Percent of Variance)
					DO I1=1,ANZ_STA
						E(I,J)=E(I,J)+P_J(I1)*MUE_OI(I1)
					End Do
					E(I,J)= ( MUE_00-E(I,J)-P_J(ANZ_NEU) ) * 100
					
					If (E(I,J) > 100.0 ) then
						E(I,J)=100.0
					end if
					
	
					
					!Err_var(I,J) = Err_var(I,J) * 	E(I,J)

				ENDIF

		End DO
		
	RETURN
	
END Subroutine Optintpkt

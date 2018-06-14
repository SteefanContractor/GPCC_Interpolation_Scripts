      SUBROUTINE GITTER(N,M,LAM,PHI,SEA) !,LAM_ALL,PHI_ALL,SEA_ALL)

!*       Reading of grid point coordinates and land/sea mask
!*       from external files.
!*
!*       F. Rubel, 30.03.1999
!*                 17.11.2005 Extended by global grid

        IMPLICIT NONE

        INTEGER 	:: N,M,N1,M1,N2,M2,I,J
        REAL 		:: LAM(N,M),PHI(N,M),SEA(N,M)
        REAL 		:: LAM_ALL(N,M),PHI_ALL(N,M),SEA_ALL(N,M)		! Wird eigentlich nicht benoetigt!!!, 

!*       FŸr 'INOUT'
!        CHARACTER(1)	:: STATUS
        CHARACTER(12)	:: DATEI
        CHARACTER(70)	:: TEXT3
        CHARACTER(80)	:: TEXT1,TEXT5

	IF (N == 360) THEN
!*         360x180-Gitter
!*         -----------
!	  DATEI='LAM_1.0_DEG'
!	  WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (LAM,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='PHI_1.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (PHI,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='SEA_1.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (SEA,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)

	 DATEI='LAM_1.0_D_R'
	 WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (LAM,N,M,1,DATEI)
	  DATEI='PHI_1.0_D_R'
	  WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (PHI,N,M,1,DATEI)
	  DATEI='SEA_1.0_D_R'
	  WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (SEA,N,M,1,DATEI)


        ELSE IF (N == 144) THEN
!*         2.5-Grad-Gitter
!*         ------------
	 DATEI='LAM_2.5_DEG'
	 WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (LAM,N,M,1,DATEI)
	  DATEI='PHI_2.5_DEG'
	  WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (PHI,N,M,1,DATEI)
	  DATEI='SEA_2.5_DEG'
	  WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (SEA,N,M,1,DATEI)


        ELSE IF (N == 720 ) THEN
!*         0.5-Grad-Gitter
!*         -----------
	 DATEI='LAM_0.5_DEG'
	 WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (LAM,N,M,1,DATEI)
	  DATEI='PHI_0.5_DEG'
	  WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (PHI,N,M,1,DATEI)
	  DATEI='SEA_0.5_DEG'
	  WRITE (6,*) 'Read '//DATEI
	  CALL INOUT (SEA,N,M,1,DATEI)


        ELSE IF (N == 12) THEN
!*         12x9-Gitter
!*         -----------
	   WRITE (6,*) 'Hier sollten jetzt eigentlich die Gitterkoordinaten eingelesen werden'
	   WRITE (6,*) 'Programmabbruch in der Subroutine "Gitter"'
	   stop
!          DATEI='LAM_5.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (LAM,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='PHI_5.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (PHI,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='SEA_5.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (SEA,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)

        ELSE IF (N == 60) THEN
!*         60x45-Gitter
!*         ------------
	   WRITE (6,*) 'Hier sollten jetzt eigentlich die Gitterkoordinaten eingelesen werden'
	   WRITE (6,*) 'Programmabbruch in der Subroutine "Gitter"'
	   stop
!          DATEI='LAM_1.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!!          CALL INOUT (LAM,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='PHI_1.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (PHI,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='SEA_1.0_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (SEA,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)

        ELSE IF (N == 120) THEN
!*         120x90-Gitter
!*         -------------
	   WRITE (6,*) 'Hier sollten jetzt eigentlich die Gitterkoordinaten eingelesen werden'
	   WRITE (6,*) 'Programmabbruch in der Subroutine "Gitter"'
	   stop
!          DATEI='LAM_0.5_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (LAM,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='PHI_0.5_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (PHI,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='SEA_0.5_DEG'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (SEA,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)


        ELSE IF (N == 40) THEN
!*         40x22-Gitter
!*         ------------
	   WRITE (6,*) 'Hier sollten jetzt eigentlich die Gitterkoordinaten eingelesen werden'
	   WRITE (6,*) 'Programmabbruch in der Subroutine "Gitter"'
	   stop
!          DATEI='LAM_1.0_CUT'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (LAM,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='PHI_1.0_CUT'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (PHI,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)
!          DATEI='SEA_1.0_CUT'
!          WRITE (6,*) 'Read '//DATEI
!          CALL INOUT (SEA,N,M,1,DATEI,TEXT1,TEXT3,TEXT5,N1,M1,N2,M2)

	ELSE IF ( N == 212 ) THEN	! und m = 206
		DATEI='LAT_2.2DEG'
		WRITE (6,*) 'Read '//DATEI
		CALL INOUT (LAM,N,M,1,DATEI)
		DATEI='LON_2.2DEG'
		WRITE (6,*) 'Read '//DATEI
		CALL INOUT (PHI,N,M,1,DATEI)
		DATEI='SEA_2.2DEG'
		WRITE (6,*) 'Read '//DATEI
		CALL INOUT (SEA,N,M,1,DATEI)
		
	End IF
	
      RETURN
      END



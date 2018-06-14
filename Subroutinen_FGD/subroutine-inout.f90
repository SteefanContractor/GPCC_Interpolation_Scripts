      SUBROUTINE INOUT(FELD,NI,NJ,NK,FILEN)
!*       W. SPANGL, 16.11.1990
!*       F. RUBEL , 05.04.1997 Anpassung an SUN Fortran 4.0


        REAL		:: FELD(NI,NJ),G
        CHARACTER(12)	:: FILEN
	
	! NI == N Anzahl Gitterpunkte in X-Richtung
	! NJ == M Anzahl Gitterpunkte in Y-Richtung


!	write(6,*) 'Datei ein ist: ', FILEN 

	! Datei mit den Koordinaten oder Land-Seemaske oeffnen und einlesen
        OPEN ( unit = 1, FILE = FILEN ) 

	!Header lesen
		READ (1,*)
		READ (1,*)
		READ (1,*)
		READ (1,*)
		READ (1,*)
		READ (1,*)
		READ (1,*)
	
	! Daten lesen
		DO J=1,NJ
			READ(1,*) (FELD(I,J),I=1,NI)		!Fuer 0.22 Grad Raster
!			if ( J < 10 ) write(6,*) Feld(1,J)
		End Do

	CLOSE(1)
      RETURN
      END

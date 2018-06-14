      REAL FUNCTION ACLP(L1,P1,L2,P2)
!       F. Hamelbeck

!       ACLP BERECHNET ACOS(SIN(P1)*SIN(P2)+COS(P1)*COS(P2)*COS(L2-L1))
!       FUNKTION WURDE EINGEFUEHRT, WEIL AUFGRUND NUMERISCHER RUNDUNGEN
!       DAS ARGUMENT ZUM ACOS EIN WENIG HOHER ALS 1. WERDEN KANN
!       INSBESONDER WENN DIE WINKEL NAHE BEIEIANDER LIEGEN
!       DANN WIRD DIE INTEFISMAL GUELTIGE FORMEL
!       ACLP=SQRT(COS(P1)**2*(L1-L2)**2+(P1-P2)**2) BENUTZT

	REAL :: L1,P1,L2,P2	! Koordinaten von Punkt 1 und Punkt 2 im Bogenmaß
	real :: radius_Erde	! mittlerer Radius der Erde
	real :: X1		! Hilfsvariable

	radius_Erde = 6378.388

	! Abstand wird in ( Bogenmaß * Erdradius) == km zurückgegeben

		X1=(SIN(P1)*SIN(P2)+COS(P1)*COS(P2)*COS(L2-L1))

		IF (X1 >= .9999995 .AND. X1 < 1.0000005 ) THEN
			ACLP=SQRT(COS(P1)**2*(L1-L2)**2+(P1-P2)**2) * radius_Erde
		ELSE IF (X1 < 1 ) THEN
			ACLP=ACOS(X1) * radius_Erde
		ELSE
			write (6,'(F20.15,A60)') X1,'  X1 .GT. 1.0000005 IN ACLP '
			write (6,'(4F12.8,A10)') L1,P1,L2,P2
			stop
		ENDIF
	RETURN
	END

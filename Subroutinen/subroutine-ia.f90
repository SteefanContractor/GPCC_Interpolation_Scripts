      INTEGER FUNCTION IA(FIELD1,NI,NJ,NK,G)
!*       M. Dorninger, 7.11.1990



        REAL 		:: FIELD1(NI,NJ,NK),G

        RMAX=FIELD1(1,1,1)
        RMIN=FIELD1(1,1,1)
        DO 100 K=1,NK
          DO 100 J=1,NJ
            DO 100 I=1,NI
              IF (FIELD1(I,J,K).GT.RMAX)RMAX=FIELD1(I,J,K)
              IF (FIELD1(I,J,K).LT.RMIN)RMIN=FIELD1(I,J,K)
100     CONTINUE
        IF (ABS(RMIN).GT.RMAX.OR.ABS(RMIN).EQ.RMAX) THEN
          XMAX=ABS(RMIN)
        ELSE
          XMAX=RMAX
        ENDIF
        IF (XMAX.EQ.0) THEN
          IA = 0
          RETURN
        ENDIF

        A1=ALOG10 ((G/10.)/XMAX)
        A2=ALOG10 ( G/XMAX )
        A=AMAX1 (A1,A2)

        IF (A.GT.0) IA=INT(A)
        IF (A.LT.0) IA=INT(A-1.0)
      RETURN
      END

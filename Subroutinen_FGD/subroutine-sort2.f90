      SUBROUTINE SORT2(M,N,RA,RB,RC,RD)
        DIMENSION RA(M),RB(M),RC(M),RD(M)
        L=N/2+1
        IR=N
10      CONTINUE
          IF (L.GT.1) THEN
        L=L-1
        RRA=RA(L)
        RRB=RB(L)
        RRC=RC(L)
        RRD=RD(L)
      ELSE
        RRA=RA(IR)
        RRB=RB(IR)
        RRC=RC(IR)
        RRD=RD(IR)
        RA(IR)=RA(1)
        RB(IR)=RB(1)
        RC(IR)=RC(1)
        RD(IR)=RD(1)
        IR=IR-1
        IF (IR.EQ.1) THEN
          RA(1)=RRA
          RB(1)=RRB
          RC(1)=RRC
          RD(1)=RRD
          RETURN
        ENDIF
      ENDIF
      I=L
      J=L+L
20    IF (J.LE.IR) THEN
        IF (J.LT.IR) THEN
          IF (RA(J).LT.RA(J+1)) J=J+1
        ENDIF
        IF (RRA.LT.RA(J)) THEN
          RA(I)=RA(J)
          RB(I)=RB(J)
          RC(I)=RC(J)
          RD(I)=RD(J)
          I=J
          J=J+J
        ELSE
          J=IR+1
        ENDIF
        GOTO 20
      ENDIF
      RA(I)=RRA
      RB(I)=RRB
      RC(I)=RRC
      RD(I)=RRD
      GOTO 10
      END




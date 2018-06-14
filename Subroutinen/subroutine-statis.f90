      SUBROUTINE STATIS(NI,NJ,NK,PHI,RMS,MW,SIG)

!*       W. SPANGL, 1.4.1990

        REAL PHI(NI,NJ,NK),SIG,MW,RMS

        N=NI*NJ*NK
        RMS=0.
        DO 10 I=1,NI
          DO 10 J=1,NJ
            DO 10 K=1,NK
              RMS=RMS+PHI(I,J,K)*PHI(I,J,K)
10      CONTINUE
        RMS=SQRT(RMS/N)
        MW=0.
        DO 11 I=1,NI
          DO 11 J=1,NJ
            DO 11 K=1,NK
              MW=MW+PHI(I,J,K)
11      CONTINUE
        MW=MW/N
        SIG=0.
        DO 12 I=1,NI
          DO 12 J=1,NJ
            DO 12 K=1,NK
              SIG=SIG+(PHI(I,J,K)-MW)*(PHI(I,J,K)-MW)
12      CONTINUE
        SIG=SQRT(SIG/N)
      RETURN
      END

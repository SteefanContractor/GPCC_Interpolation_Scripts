      SUBROUTINE GAUSS(M,N,A,B,C,P,X)
!*       Lineares Gleichungssystem (Gausssches Eliminationsverfahren)
!*
!*       F. Rubel, 21.7.1993


        IMPLICIT NONE

        INTEGER I,J,K,N,M
        REAL DET,MAX,S,Q,H
        REAL A(M,M),B(M),C(M),X(M)
        INTEGER P(M)

!*       Berechnung der Determinante
!*       ---------------------------
	DET=1
	DO K=1,N-1
		MAX=0
		P(K)=0
		DO I=K,N
			S=0
			DO J=K,N
				S=S+ABS(A(I,J))
			End Do
			Q=ABS(A(I,K))/S
			IF (Q.GT.MAX) THEN
				MAX=Q
				P(K)=I
			ENDIF
		End Do

		IF (MAX.EQ.0) GOTO 500
		IF (P(K).NE.K) THEN
		  DET=-DET
			DO J=1,N
				H=A(K,J)
				A(K,J)=A(P(K),J)
				A(P(K),J)=H
			End DO
		ENDIF
		DET=DET*A(K,K)

		DO I=K+1,N
			A(I,K)=A(I,K)/A(K,K)
			DO J=K+1,N
				A(I,J)=A(I,J)-A(I,K)*A(K,J)
			End DO
		End Do
500     CONTINUE
	End DO
	DET=DET*A(N,N)

70    FORMAT(1F12.4)

!*     Vorwaertseinsetzen
!*     -----------------
	DO K=1,N-1
		IF (P(K).NE.K) THEN
			H=B(K)
			B(K)=B(P(K))
			B(P(K))=H
		ENDIF
	End DO
	DO I=1,N
		C(I)=B(I)
		DO J=1,I-1
			C(I)=C(I)-A(I,J)*C(J)
		End do
	End DO

!*     Rueckwaertseinsetzen
!*     ------------------
	DO I=1,N
		X(I)=0
	End DO
	DO I=N,1,-1
		S=C(I)
		DO K=I+1,N
			S=S+A(I,K)*X(K)
		End DO
		X(I)=-S/A(I,I)
	End Do
130   FORMAT (I2,F12.4)

	DO I=1,N
		X(I)=-X(I)
	End DO

      END

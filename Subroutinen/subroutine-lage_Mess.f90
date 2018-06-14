!~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~***
!*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~	  
!
!	SUBROUTINE lage_Mess  --> zählt wieviele Stationen in einer Gitterbox drin sind und erstellt Datei für Grads zum Plotten
!
!*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~	  
!~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~***

subroutine lage_Mess ( Lon_M, Lat_M, Lon_G,Lat_G,  NS_M, Anz_Box_y, Anz_Box_x, Anz_Mess, SEA, Anz_Stat_in_Box)

!	call read_Mess(Datei_ein, Lat_M, Lon_M, Lam_M, Phi_M, NS_M, Anz_Mess, Anz_Char)
!	Subroutine zum einlesen der Messwerte und der dazugehörigen Koordinaten, Lam und Phi sind hier eigentlich noch überflüssig, werden in Interpolation erst umgerechnet

Implicit None

	REAL				 :: Lat_M(Anz_Mess), Lon_M(Anz_Mess)
	REAL, intent(inout)		 :: Lat_G(Anz_Box_x, Anz_Box_y), Lon_G(Anz_Box_x, Anz_Box_y), SEA(Anz_Box_x, Anz_Box_y)
	REAL, intent(in)		 :: NS_M(Anz_Mess)
	REAL				 :: Gitterweite
	INTEGER				 :: Anz_Stat_in_Box(Anz_Box_x, Anz_Box_y)
	REAL				 :: NS_Sum(Anz_Box_x, Anz_Box_y)
	INTEGER				 :: I, J, K, Sum, zaehl
	INTEGER, intent(in)		 :: Anz_Mess, Anz_Box_y, Anz_Box_x
	REAL				 :: L1, L2, P1, P2
	REAL				 :: Test(Anz_Mess)
	real				 :: pii	
	
!~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~
Anz_Stat_in_Box = 0
Sum = 0
NS_Sum = 0
pii = 4.*atan(1.)

Gitterweite = (360/Anz_Box_x)

Test = Lat_M


	DO I = 1, Anz_Box_x
		Do K = 1, Anz_Box_y
			L1 = Lat_G(I,K)*360/(2*pii)
			P1 = Lon_G(I,K)*360/(2*pii)
			zaehl = 0
			IF (SEA(I,K) > 0) THEN
				DO J = 1, Anz_Mess
				L2 = Lat_M(J)*360/(2*pii)
				P2 = Lon_M(J)*360/(2*pii)
!				IF ((J == 208) .AND. (I + K == 2)) write(6,*) Lat_M(J), Lon_M(J), L1 + Gitterweite/2, P1+ Gitterweite/2												
					IF ((L1 + Gitterweite/2) >= L2 .AND. (L1 - Gitterweite/2) < L2 ) Then
						IF ((P1+ Gitterweite/2) >= P2 .AND. (P1- Gitterweite/2) < P2) Then
							Anz_Stat_in_Box(I,K) = Anz_Stat_in_Box(I,K) + 1
							IF (NS_M(J) < 0) THEN
								write(6,*) 'Negative Werte in Messungen!'
								stop
							END IF
							NS_Sum(I,K) = NS_Sum(I,K) + NS_M(J)
							Sum = Sum + 1		! Anzahl Stationen die insgesamt zugeordnet werden (Alle Raster)
							zaehl = zaehl + 1	! Anzahl Stationen im Raster
							Test(J) = 999
!							write(6,*) 'Anzahl im Raster ist ', zaehl, Sum, Anz_Mess
						END IF
					END IF
				END DO
				IF (NS_Sum(I,K) > 0) THEN
					NS_Sum(I,K) = NS_Sum(I,K) / zaehl
				ELSE IF ((zaehl > 0) .AND. (NS_Sum(I,K) == 0)) Then
					NS_Sum(I,K) = 0
				ELSE
					NS_Sum(I,K) = -999
				END IF	
			ELSE
				NS_Sum(I,K) = -999
				Anz_Stat_in_Box(I,K) = -99999.99
			END IF
		end do
	end do
	
	
!	write(6,*) 'Gitterweite ist ', Gitterweite


end subroutine lage_Mess

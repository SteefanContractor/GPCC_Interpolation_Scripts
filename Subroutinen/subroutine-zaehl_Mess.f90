!~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~***
!*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~	  
!
!	SUBROUTINE read_Mess  --> liest Lat Lon und Value der Messstationen ein
!
!*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~	  
!~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~***

subroutine zaehl_Mess(Datei_ein, Anz_Mess)
!	call zaehl_Mess(Datei_ein, Anz_Mess)
!	Subroutine zum, zählen der Anzahl der Messwerte in der gewünschten Datei. Wird für Subroutine read_Mess benötigt um Variablen zu allokieren

IMPLICIT NONE

	INTEGER, intent(out)		 :: Anz_Mess 
	INTEGER				 :: Anz_Char, x
	INTEGER                   	 :: read_error, io_error   ! Fehlerbehandlung bei read
	CHARACTER(500), intent(in)	 :: Datei_ein

!~~~~~~~~~~~~~~~*****************~~~~~~~~~~~~~~~
	
	read_error = 0
	Anz_Mess = 0

	x = index(Datei_ein,' ')
	open( unit = 1, file = Datei_ein(1:(x-1)), status='old', action='read', iostat=io_error) 
 	    if (io_error /= 0) then  							! Beim oeffnen ist ein Fehler aufgetreten
		    write(6,*) 'Beim Versuch, die Datei ', Datei_ein(1:(x-1)), ' mit den Messwerten zu oeffnen, ist ein Fehler aufgetreten.', x
		    stop
	    end if

		Do while (read_error == 0)
	    		read(1,'(A)',iostat = read_error)
		       	Anz_Mess = Anz_Mess + 1
	    	end do
	    	Anz_Mess = Anz_Mess -1
	close (unit = 1)

end subroutine zaehl_Mess

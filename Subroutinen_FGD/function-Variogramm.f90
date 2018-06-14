!	#####################################################################################
!	#                                                                                   #
!	#                  Funktion Variogramm					            #
!	#                                                                                   #
!	#####################################################################################
!
real function Variogramm(OBS_ERR, Param_ACF_A,  Param_ACF_B, D)

	implicit none

		real 		:: OBS_ERR		! 
		real 		:: Param_ACF_A		! 
		real 		:: Param_ACF_B		! 
		real 		:: D			! Abstand
		
		
			Variogramm = ( 1 - OBS_ERR ) * EXP( -Param_ACF_A * D  ** Param_ACF_B )
	
		return

end function Variogramm


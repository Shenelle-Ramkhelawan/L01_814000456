			LIST p=18f452
			INCLUDE <P18F452.INC>
					
			CBLOCK		0x480
			MapName:8
			ENDC
			
			EXTERN		MapIndex
			
filter			CODE
			
			
intMapName	
			movlw		0x4D          ; M
			movwf		0x480

			movlw		0x61          ; a
			movwf		0x481

			movlw		0x70	      ; p
			movwf		0x482

			movlw		0x4E	      ; N
			movwf		0x483

			movlw		0x61	      ; a
			movwf		0x484

			movlw		0x6D	      ; m
			movwf		0x485   

			movlw		0x65	      ; e
			movwf		0x486

			movlw		0x00	      ; Null
			movwf		0x487
			
getMapChar
			movlw		0x07
			cpfsgt		MapIndex,0
			goto		sendMapChar
			goto		invalidIndex
			
sendMapChar
			lfsr		FSR0, 0x480
			movf		MapIndex,W
			movf		PLUSW0,W
			return

invalidIndex		
			movlw		0xFF
			return
			
			GLOBAL		intMapName
			GLOBAL		getMapChar
			
			END
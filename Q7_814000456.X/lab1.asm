;label			instruction			operand			comment
;			directive

			LIST				p=18f452		;tell assembler what chip we are using
			INCLUDE				<p18f452.inc>
				

			GLOBAL				getMapChar,intMapName
			GLOBAL				MapName	
			
grp0			UDATA				0x90
MapName			RES				8
			CBLOCK				0x90
			MapName1
			MapName2
			MapName3
			MapName4
			MapName5
			MapName6
			MapName7
			ENDC
			
			EXTERN				MapIndex
RST			CODE				0x80			;The code section named RST
			pagesel				getMapChar		;Jumps to the location labelled
			goto 				getMapChar
PGM			CODE
						

intMapName		
			movlw				0x54
			movwf				MapName1
			movlw				0x41
			movwf				MapName2
			movlw				0x50
			movwf				MapName3
			movlw				0x4F
			movwf				MapName4
			movlw				0x55
			movwf				MapName5
			movlw				0x54
			movwf				MapName6
			movlw				0x21
			movwf				MapName7
			return
			
			
getMapChar			
			lfsr				0,MapName		;load 12bit file address point to FSR0
			movf				MapIndex,W		;load MapIndex to WREG
			addwf				FSR0L,F			;add mapIndex to FSR0 low byte
			movf				INDF0,W			;load MapName[mapIndex] to WREG
			return
		
			END



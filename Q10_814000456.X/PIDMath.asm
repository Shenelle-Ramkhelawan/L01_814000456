;********************************************************
;This file contains the following math routines:

;24-bit addittion		
;24-bit subtraction
	
;16*16 	Unsigned Multiply	
							
;24/16 	Unsigned Divide			
			
	list		p=18F452       
	#include	<p18F452.inc> 

	#define	_Z		STATUS,2
	#define	_C		STATUS,0
	
	GLOBAL	AARGB0,AARGB1,AARGB2,AARGB3		
	GLOBAL	BARGB0,BARGB1,BARGB2,BARGB3
	GLOBAL	ZARGB0,ZARGB1,ZARGB2
	GLOBAL	REMB0,REMB1
	GLOBAL	TEMP,TEMPB0,TEMPB1,TEMPB2,TEMPB3
	GLOBAL	LOOPCOUNT,AEXP,CARGB2

	
LSB			equ	0
MSB			equ	7

math_data	UDATA	
AARGB0		RES 1		
AARGB1		RES 1
AARGB2		RES 1
AARGB3		RES 1
BARGB0		RES 1	
BARGB1		RES 1
BARGB2		RES 1
BARGB3		RES 1
REMB0		RES 1	
REMB1		RES 1
REMB2		RES 1
REMB3		RES 1	
TEMP		RES 1
TEMPB0		RES 1
TEMPB1		RES 1
TEMPB2		RES 1
TEMPB3		RES 1
ZARGB0		RES 1
ZARGB1		RES 1
ZARGB2		RES 1
CARGB2		RES	1
AEXP		RES 1
LOOPCOUNT	RES 1


math_code	CODE
;---------------------------------------------------------------------
;		24-BIT ADDITION				
_24_BitAdd
	GLOBAL	_24_BitAdd
	movf	BARGB2,w
	addwf	AARGB2,f

	movf	BARGB1,w
	btfsc	_C
	incfsz	BARGB1,w
	addwf	AARGB1,f
	
	movf	BARGB0,w
	btfsc	_C
	incfsz	BARGB0,w
	addwf	AARGB0,f
	return

;---------------------------------------------------------------------
;		24-BIT SUBTRACTION			
_24_bit_sub
	GLOBAL	_24_bit_sub
	movf	BARGB2,w
	subwf	AARGB2,f	

	movf	BARGB1,w
	btfss	STATUS,C
	incfsz	BARGB1,w
	subwf	AARGB1,f

	movf	BARGB0,w
	btfss	STATUS,C
	incfsz	BARGB0,w
	subwf	AARGB0,f
	return

;-------------------------------------------------------------------------
;       16x16 Bit Unsigned Fixed Point Multiply 16 x 16 -> 32

FXM1616U
		GLOBAL	FXM1616U

		MOVFF	AARGB1,TEMPB1	

		MOVF	AARGB1,W
		MULWF	BARGB1
		MOVFF	PRODH,AARGB2
		MOVFF	PRODL,AARGB3
		
		MOVF	AARGB0,W
		MULWF	BARGB0
		MOVFF	PRODH,AARGB0
		MOVFF	PRODL,AARGB1

		MULWF	BARGB1
		MOVF	PRODL,W
		ADDWF	AARGB2,F
		MOVF	PRODH,W
		ADDWFC	AARGB1,F
		CLRF	WREG
		ADDWFC	AARGB0,F

		MOVF	TEMPB1,W
		MULWF	BARGB0
		MOVF	PRODL,W
		ADDWF	AARGB2,F
		MOVF	PRODH,W
		ADDWFC	AARGB1,F
		CLRF	WREG
		ADDWFC	AARGB0,F
		
		RETLW	0x00

;--------------------------------------------------------------------
FXD2416U		
		GLOBAL		FXD2416U
		CLRF		REMB0
		CLRF		REMB1
		CLRF		WREG
		TSTFSZ		BARGB0
		GOTO		D2416BGT1
		MOVFF		BARGB1,BARGB0
		CALL		FXD2408U
		MOVFF		REMB0,REMB1
		CLRF		REMB0
		RETLW		0x00

D2416BGT1
		CPFSEQ		AARGB0
		GOTO		D2416AGTB
		MOVFF		AARGB1,AARGB0
		MOVFF		AARGB2,AARGB1
		CALL		FXD1616U
		
		MOVFF		AARGB1,AARGB2
		MOVFF		AARGB0,AARGB1
		CLRF		AARGB0
		RETLW		0x00
D2416AGTB
		MOVFF		AARGB2,AARGB3
		MOVFF		AARGB1,AARGB2
		MOVFF		AARGB0,AARGB1
		CLRF		AARGB0

		MOVFF		AARGB0,TEMPB0
		MOVFF		AARGB1,TEMPB1
		MOVFF		AARGB2,TEMPB2
		MOVFF		AARGB3,TEMPB3

		MOVLW		0x02			; set loop count
		MOVWF		AEXP

		MOVLW		0x01
		MOVWF		ZARGB0

		BTFSC		BARGB0,MSB
		GOTO		D2416UNRMOK

		CALL		DGETNRMD		; get normalization factor
		MOVWF		ZARGB0

		MULWF		BARGB1
		MOVF		BARGB0,W
		MOVFF		PRODL,BARGB1
		MOVFF		PRODH,BARGB0
		MULWF		ZARGB0
		MOVF		PRODL,W
		ADDWF		BARGB0,F

		MOVF		ZARGB0,W
		MULWF		AARGB3
		MOVFF		PRODL,TEMPB3
		MOVFF		PRODH,TEMPB2
		MULWF		AARGB1
		MOVFF		PRODL,TEMPB1
		MOVFF		PRODH,TEMPB0
		MULWF		AARGB2
		MOVF		PRODL,W
		ADDWF		TEMPB2,F
		MOVF		PRODH,W
		ADDWF		TEMPB1,F

D2416UNRMOK
		BCF		_C
		CLRF		TBLPTRH
		RLCF		BARGB0,W
		RLCF		TBLPTRH,F
		ADDLW		LOW (IBXTBL256+1)	; access reciprocal table
		MOVWF		TBLPTRL
		MOVLW		HIGH (IBXTBL256)
		ADDWFC		TBLPTRH,F
		TBLRD		*-

D2416ULOOP
		MOVFF		TEMPB0,AARGB0
		MOVFF		TEMPB1,AARGB1

		CALL		FXD1608U2		; estimate quotient digit

		BTFSS		AARGB0,LSB
		GOTO		D2416UQTEST

		SETF		AARGB1
		MOVFF		TEMPB1,REMB0
		MOVF		BARGB0,W
		ADDWF		REMB0,F

		BTFSC		_C
		GOTO		D2416UQOK

D2416UQTEST
		MOVF		AARGB1,W		; test
		MULWF		BARGB1

		MOVF		PRODL,W
		SUBWF		TEMPB2,W
		MOVF		PRODH,W
		SUBWFB		REMB0,W

		BTFSC		_C
		GOTO		D2416UQOK

		DECF		AARGB1,F

		MOVF		BARGB0,W
		ADDWF		REMB0,F

		BTFSC		_C
		GOTO		D2416UQOK

		MOVF		AARGB1,W
		MULWF		BARGB1

		MOVF		PRODL,W
		SUBWF		TEMPB2,W
		MOVF		PRODH,W
		SUBWFB		REMB0,W

		BTFSS		_C
		DECF		AARGB1,F

D2416UQOK
		MOVFF		AARGB1,ZARGB1

		MOVF		AARGB1,W
		MULWF		BARGB1
		MOVF		PRODL,W
		SUBWF		TEMPB2,F
		MOVF		PRODH,W
		SUBWFB		TEMPB1,F

		MOVF		AARGB1,W
		MULWF		BARGB0
		MOVF		PRODL,W
		SUBWF		TEMPB1,F
		MOVF		PRODH,W
		SUBWFB		TEMPB0,F

		BTFSS		TEMPB0,MSB		; test
		GOTO		D2416QOK
		DECF		ZARGB1,F

		MOVF		BARGB1,W
		ADDWF		TEMPB2,F
		MOVF		BARGB0,W
		ADDWFC		TEMPB1,F

D2416QOK
		DCFSNZ		AEXP,F			; is loop done?
		GOTO		D2416FIXREM

		MOVFF		ZARGB1,ZARGB2

		MOVFF		TEMPB1,TEMPB0
		MOVFF		TEMPB2,TEMPB1
		MOVFF		TEMPB3,TEMPB2

		GOTO		D2416ULOOP		

D2416FIXREM
		MOVFF		TEMPB1,REMB0
		MOVFF		TEMPB2,REMB1

		MOVLW		0x01
		CPFSGT		ZARGB0
		GOTO		D2416REMOK
		RRNCF		ZARGB0,W
		MOVWF		BARGB0
		CALL		DGETNRMD

		MULWF		TEMPB2
		MOVFF		PRODH,REMB1
		MULWF		TEMPB1
		MOVF		PRODL,W
		ADDWF		REMB1,F
		MOVFF		PRODH,REMB0

D2416REMOK
		CLRF		AARGB0
		MOVFF		ZARGB1,AARGB2
		MOVFF		ZARGB2,AARGB1

		RETLW		0x00
		
;----------------------------------------------------		
FXD2408U
		MOVFF		AARGB0,TEMPB0
		MOVFF		AARGB1,TEMPB1
		MOVFF		AARGB2,TEMPB2

		CALL		FXD1608U

		MOVFF		AARGB0,TEMPB0
		MOVFF		AARGB1,TEMPB1

		MOVFF		TEMPB2,AARGB1
		MOVFF		REMB0,AARGB0

		CALL		FXD1608U
		
		MOVFF		AARGB1,AARGB2
		MOVFF		TEMPB1,AARGB1
		MOVFF		TEMPB0,AARGB0

		RETLW		0x00
		
;--------------------------------------------------------
FXD1608U
		GLOBAL		FXD1608U

		MOVLW		0x01
		CPFSGT		BARGB0
		GOTO		DREMZERO8

FXD1608U1
		GLOBAL		FXD1608U1

		BCF		_C
		CLRF		TBLPTRH
		RLCF		BARGB0,W
		RLCF		TBLPTRH,F
		ADDLW		LOW (IBXTBL256+1)	; access reciprocal table
		MOVWF		TBLPTRL
		MOVLW		HIGH (IBXTBL256)
		ADDWFC		TBLPTRH,F
		TBLRD		*-

FXD1608U2
		GLOBAL		FXD1608U2

		MOVFF		AARGB0,REMB1
		MOVFF		AARGB1,REMB0

		MOVF		TABLAT,W		; estimate quotient
		MULWF		REMB1
		MOVFF		PRODH,AARGB0
		MOVFF		PRODL,AARGB1

		TBLRD		*+
		MOVF		TABLAT,W
		MULWF		REMB0
		MOVFF		PRODH,AARGB2

		MULWF		REMB1
		MOVF		PRODL,W
		ADDWF		AARGB2,F
		MOVF		PRODH,W
		ADDWFC		AARGB1,F
		CLRF		WREG
		ADDWFC		AARGB0,F

		TBLRD		*-
		MOVF		TABLAT,W
		MULWF		REMB0
		MOVF		PRODL,W
		ADDWF		AARGB2,F
		MOVF		PRODH,W
		ADDWFC		AARGB1,F
		CLRF		WREG
		ADDWFC		AARGB0,F
		
		MOVF		BARGB0,W
		MULWF		AARGB1
		MOVFF		PRODL,AARGB3
		MOVFF		PRODH,AARGB2
		MULWF		AARGB0
		MOVF		PRODL,W
		ADDWF		AARGB2,F

		MOVF		AARGB3,W		; estimate remainder
		SUBWF		REMB0,F
		MOVF		AARGB2,W
		SUBWFB		REMB1,F

		BTFSS		REMB1,MSB		; test remainder
		RETLW		0x00

		DECF		AARGB1,F
		CLRF		WREG
		SUBWFB		AARGB0,F

		MOVF		BARGB0,W
		ADDWF		REMB0,F

        RETLW       0x00
        
        
;----------------------------------------------------------
FXD1616U
		TSTFSZ		BARGB0
		GOTO		D1616B0GT0
		MOVFF		BARGB1,BARGB0
		CALL		FXD1608U
		MOVFF		REMB0,REMB1
		CLRF		REMB0

		RETLW		0x00

D1616B0GT0
		MOVF		BARGB0,W
		SUBWF		AARGB0,W
		BTFSS		_C
		GOTO		D1616QZERO
		BTFSS		_Z
		GOTO		D1616AGEB

		MOVF		BARGB1,W
		SUBWF		AARGB1,W
		BTFSS		_C
		GOTO		D1616QZERO

D1616AGEB
		MOVFF		AARGB0,TEMPB0
		MOVFF		AARGB1,TEMPB1

		MOVFF		AARGB1,CARGB2
		MOVFF		AARGB0,AARGB1
		CLRF		AARGB0

		MOVFF		BARGB0,BARGB2
		MOVFF		BARGB1,BARGB3

		BTFSC		BARGB0,MSB
		GOTO		D1616UNRMOK

		MOVF		BARGB0,W
		RLNCF		WREG,F
		ADDLW		LOW (IBXTBL256+3)	; access reciprocal table
		MOVWF		TBLPTRL
		MOVLW		HIGH (IBXTBL256)
		CLRF		TBLPTRH
		ADDWFC		TBLPTRH,F
		TBLRD		*

		MOVF		TABLAT,W		; normalize
		MULWF		BARGB3
		MOVFF		PRODL,BARGB1
		MOVFF		PRODH,BARGB0
		MULWF		BARGB2
		MOVF		PRODL,W
		ADDWF		BARGB0,F

		MOVF		TABLAT,W
		MULWF		TEMPB1
		MOVFF		PRODL,CARGB2
		MOVFF		PRODH,AARGB1
		MULWF		TEMPB0
		MOVF		PRODL,W
		ADDWF		AARGB1,F
		CLRF		AARGB0
		MOVF		PRODH,W
		ADDWFC		AARGB0,F

D1616UNRMOK
		CALL		FXD1608U1		; estimate quotient digit

		MOVF		AARGB1,W
		MULWF		BARGB1

		MOVF		PRODL,W
		SUBWF		CARGB2,W
		MOVF		PRODH,W
		SUBWFB		REMB0,W

		BTFSS		_C			; test
		DECF		AARGB1,F

D1616UQOK
		MOVF		AARGB1,W		; calculate remainder
		MULWF		BARGB3
		MOVF		PRODL,W
		SUBWF		TEMPB1,F
		MOVF		PRODH,W
		SUBWFB		TEMPB0,F

		MOVF		AARGB1,W
		MULWF		BARGB2
		MOVF		PRODL,W
		SUBWF		TEMPB0,F

;	This test does not appear to be necessary in the 16 bit case, but
;	is included here in the event that a case appears after testing.

;		BTFSS		TEMPB0,MSB		; test
;		GOTO		D1616QOK
;		DECF		AARGB1

;		MOVF		BARGB3,W
;		ADDWF		TEMPB1
;		MOVF		BARGB2,W
;		ADDWFC		TEMPB0

D1616QOK
		MOVFF		TEMPB0,REMB0
		MOVFF		TEMPB1,REMB1

		RETLW       0x00	
;---------------------------------------------------------
DGETNRMD
		MOVLW		0x10
		CPFSLT		BARGB0
		GOTO		DGETNRMDH
DGETNRMDL
		BTFSC		BARGB0,3
		RETLW		0x10		
		BTFSC		BARGB0,2
		RETLW		0x20		
		BTFSC		BARGB0,1
		RETLW		0x40
		BTFSC		BARGB0,0
		RETLW		0x80
DGETNRMDH
		BTFSC		BARGB0,6
		RETLW		0x02		
		BTFSC		BARGB0,5
		RETLW		0x04		
		BTFSC		BARGB0,4
		RETLW		0x08

;----------------------------------------------------------------------------------------------
;	Routines for the trivial cases when the quotient is zero.
;	Timing:	9,7,5	clks
;   PM: 9,7,5               DM: 8,6,4

;D3232QZERO
;		MOVFF		AARGB3,REMB3
;		CLRF		AARGB3
		
;D2424QZERO
;		MOVFF		AARGB2,REMB2
;		CLRF		AARGB2
		
D1616QZERO
		MOVFF		AARGB1,REMB1
		CLRF		AARGB1
		MOVFF		AARGB0,REMB0
		CLRF		AARGB0
		RETLW		0x00

DREMZERO8
		CLRF		REMB0
		RETLW		0x00

;----------------------------------------------------------------------------------------------
;	The table IBXTBL256 is used by all routines and consists of 16-bit
;	upper bound approximations to the reciprocal of BARGB0.

IBXTBL256
		GLOBAL	IBXTBL256

		DATA	0x0000
		DATA	0x0001
		DATA	0x8001
		DATA	0x5556
		DATA	0x4001
		DATA	0x3334
		DATA	0x2AAB
		DATA	0x2493
		DATA	0x2001
		DATA	0x1C72
		DATA	0x199A
		DATA	0x1746
		DATA	0x1556
		DATA	0x13B2
		DATA	0x124A
		DATA	0x1112
		DATA	0x1001
		DATA	0x0F10
		DATA	0x0E39
		DATA	0x0D7A
		DATA	0x0CCD
		DATA	0x0C31
		DATA	0x0BA3
		DATA	0x0B22
		DATA	0x0AAB
		DATA	0x0A3E
		DATA	0x09D9
		DATA	0x097C
		DATA	0x0925
		DATA	0x08D4
		DATA	0x0889
		DATA	0x0843
		DATA	0x0801
		DATA	0x07C2
		DATA	0x0788
		DATA	0x0751
		DATA	0x071D
		DATA	0x06EC
		DATA	0x06BD
		DATA	0x0691
		DATA	0x0667
		DATA	0x063F
		DATA	0x0619
		DATA	0x05F5
		DATA	0x05D2
		DATA	0x05B1
		DATA	0x0591
		DATA	0x0573
		DATA	0x0556
		DATA	0x053A
		DATA	0x051F
		DATA	0x0506
		DATA	0x04ED
		DATA	0x04D5
		DATA	0x04BE
		DATA	0x04A8
		DATA	0x0493
		DATA	0x047E
		DATA	0x046A
		DATA	0x0457
		DATA	0x0445
		DATA	0x0433
		DATA	0x0422
		DATA	0x0411
		DATA	0x0401
		DATA	0x03F1
		DATA	0x03E1
		DATA	0x03D3
		DATA	0x03C4
		DATA	0x03B6
		DATA	0x03A9
		DATA	0x039C
		DATA	0x038F
		DATA	0x0382
		DATA	0x0376
		DATA	0x036A
		DATA	0x035F
		DATA	0x0354
		DATA	0x0349
		DATA	0x033E
		DATA	0x0334
		DATA	0x032A
		DATA	0x0320
		DATA	0x0316
		DATA	0x030D
		DATA	0x0304
		DATA	0x02FB
		DATA	0x02F2
		DATA	0x02E9
		DATA	0x02E1
		DATA	0x02D9
		DATA	0x02D1
		DATA	0x02C9
		DATA	0x02C1
		DATA	0x02BA
		DATA	0x02B2
		DATA	0x02AB
		DATA	0x02A4
		DATA	0x029D
		DATA	0x0296
		DATA	0x0290
		DATA	0x0289
		DATA	0x0283
		DATA	0x027D
		DATA	0x0277
		DATA	0x0271
		DATA	0x026B
		DATA	0x0265
		DATA	0x025F
		DATA	0x025A
		DATA	0x0254
		DATA	0x024F
		DATA	0x024A
		DATA	0x0244
		DATA	0x023F
		DATA	0x023A
		DATA	0x0235
		DATA	0x0231
		DATA	0x022C
		DATA	0x0227
		DATA	0x0223
		DATA	0x021E
		DATA	0x021A
		DATA	0x0215
		DATA	0x0211
		DATA	0x020D
		DATA	0x0209
		DATA	0x0205
		DATA	0x0201
		DATA	0x01FD
		DATA	0x01F9
		DATA	0x01F5
		DATA	0x01F1
		DATA	0x01ED
		DATA	0x01EA
		DATA	0x01E6
		DATA	0x01E2
		DATA	0x01DF
		DATA	0x01DB
		DATA	0x01D8
		DATA	0x01D5
		DATA	0x01D1
		DATA	0x01CE
		DATA	0x01CB
		DATA	0x01C8
		DATA	0x01C4
		DATA	0x01C1
		DATA	0x01BE
		DATA	0x01BB
		DATA	0x01B8
		DATA	0x01B5
		DATA	0x01B3
		DATA	0x01B0
		DATA	0x01AD
		DATA	0x01AA
		DATA	0x01A7
		DATA	0x01A5
		DATA	0x01A2
		DATA	0x019F
		DATA	0x019D
		DATA	0x019A
		DATA	0x0198
		DATA	0x0195
		DATA	0x0193
		DATA	0x0190
		DATA	0x018E
		DATA	0x018B
		DATA	0x0189
		DATA	0x0187
		DATA	0x0184
		DATA	0x0182
		DATA	0x0180
		DATA	0x017E
		DATA	0x017B
		DATA	0x0179
		DATA	0x0177
		DATA	0x0175
		DATA	0x0173
		DATA	0x0171
		DATA	0x016F
		DATA	0x016D
		DATA	0x016B
		DATA	0x0169
		DATA	0x0167
		DATA	0x0165
		DATA	0x0163
		DATA	0x0161
		DATA	0x015F
		DATA	0x015D
		DATA	0x015B
		DATA	0x0159
		DATA	0x0158
		DATA	0x0156
		DATA	0x0154
		DATA	0x0152
		DATA	0x0151
		DATA	0x014F
		DATA	0x014D
		DATA	0x014B
		DATA	0x014A
		DATA	0x0148
		DATA	0x0147
		DATA	0x0145
		DATA	0x0143
		DATA	0x0142
		DATA	0x0140
		DATA	0x013F
		DATA	0x013D
		DATA	0x013C
		DATA	0x013A
		DATA	0x0139
		DATA	0x0137
		DATA	0x0136
		DATA	0x0134
		DATA	0x0133
		DATA	0x0131
		DATA	0x0130
		DATA	0x012F
		DATA	0x012D
		DATA	0x012C
		DATA	0x012A
		DATA	0x0129
		DATA	0x0128
		DATA	0x0126
		DATA	0x0125
		DATA	0x0124
		DATA	0x0122
		DATA	0x0121
		DATA	0x0120
		DATA	0x011F
		DATA	0x011D
		DATA	0x011C
		DATA	0x011B
		DATA	0x011A
		DATA	0x0119
		DATA	0x0117
		DATA	0x0116
		DATA	0x0115
		DATA	0x0114
		DATA	0x0113
		DATA	0x0112
		DATA	0x0110
		DATA	0x010F
		DATA	0x010E
		DATA	0x010D
		DATA	0x010C
		DATA	0x010B
		DATA	0x010A
		DATA	0x0109
		DATA	0x0108
		DATA	0x0107
		DATA	0x0106
		DATA	0x0105
		DATA	0x0104
		DATA	0x0103
		DATA	0x0102
		DATA	0x0101	
 
		end

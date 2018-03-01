;**** Timer **** 
TSCR1 EQU $46
TSCR2 EQU $4D
TIOS  EQU $40
TCTL1 EQU $48
TCTL2 EQU $49
TFLG1 EQU $4E
TIE   EQU $4C
TSCNT EQU $44
TC4	  EQU $58
TC1	  EQU $52
;***************

;*** PORTS **** 
DDRA  EQU $02
PORTA EQU $00
PORTB EQU $01
DDRB  EQU $03
PORTM EQU $0250
DDRM  EQU $0252
;**************

;*** ADC Unit *** 
ATDCTL2	EQU $122
ATDCTL4 EQU $124
ATDCTL5 EQU $125
ADTSTAT0 EQU $126
ATD1DR1H EQU $132
ATD1DR1L EQU $133
;****************		
		
		ORG		$1000
DutyCycle		ds 2
		ORG $400
			
		ldaa #$90
		staa TSCR1
	
		ldaa #$03
		staa TSCR2
	
		ldaa #$02
		staa TIOS
		
		LDAA #$FF
		STAA DDRA
		
		LDAA #$00
		staa DDRB

Detect		 	LDAA PORTB; load the input to accumulator A
				
compare1		cmpa #$F0; compare for Empty
				bgt compare2; if not true branch to half
empty			ldaa #$00; if true all lights are off
				staa PORTA
				ldd #!500
				std DutyCycle
				bra Motor
				
compare2	 	cmpa #$F1; compare for Quarter Full
			    bgt compare3; if not true branch to half
				beq Quarter;
				blt empty;
Quarter			ldaa #$03; if true turn on  2 lights of PORTA
			 	staa PORTA
				ldd #!350
				std DutyCycle
				bra Motor
		
compare3		cmpa #$F2; compare for half Full
			 	bgt compare4; if not true branch to ThreeQuarter			
				beq half;
				blt Quarter;
half			ldd #$0F; if true turn on 4 lights of PORTA
				std PORTA
				ldd #!250
				std DutyCycle
				bra Motor
		
compare4  		cmpa #$F4; compare for ThreeQuarter Full
				bgt compare5; if not true branch to Full
				beq ThreeQuarter
				blt half
ThreeQuarter	ldaa #$3F; if true turn on 6 lights of PORTA
				staa PORTA
				ldd #!150
				std DutyCycle
				bra Motor
				
compare5		cmpa #$F8; compare for Full
				beq Full;
				blt ThreeQuarter
Full			ldaa #$FF; turn on 8 lights of PORTA
				staa PORTA
				ldd #!0
				std DutyCycle
				bra Motor
				
Motor			ldaa PORTB
				cmpa #$F0
				beq Detect
				ldd TSCNT
	 			addd #!150
	 			addd DutyCycle
	 			std TC1
	
				ldaa #$08
	 			staa TCTL2
	
wait1 			brclr TFLG1,$02,wait1	
	
	 			ldd TSCNT
	 
	 			addd #!1024
	 			subd DutyCycle
	 			std TC1
	 
	 			ldaa #$0C
	 	  		staa TCTL2
	
wait2 			brclr TFLG1,$02,wait2
	  			
				bra MOTOR
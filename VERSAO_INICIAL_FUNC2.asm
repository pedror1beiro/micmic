//.include<m128def.inc>   ; Inclui as definições do ATmega128

.CSEG
.ORG 0                          ; Início do código no endereço 0

MAIN:
//CODIGO PARA INICIAR O STACK POINTER

	ldi r16, 0xFF
	out SPL, r16
	ldi r16, 0x10
	out SPH, r16

	ldi r16, 0b11111111
	out DDRC,r16
	out PORTC,r16
	
	ldi r16, 0b00000000
	out DDRA, r16

LOOP:

	IN r16,PINA
	CPI r16,0b11111110
	BREQ SEQUENCIALEDSON

	//IN r16,PINA
	//CPI r16,0b11011111
	//BRNE SEQUENCIAOFF

    RJMP LOOP                  

SEQUENCIALEDSON:
    LDI R16, 0b11111110       ; Carrega o valor inicial do LED (D1 ligado)
    OUT PORTC, R16               ; Liga o LED D1
    CALL delay     
	CALL delay  
	
	           
    LDI R16,0b11111100                      ; Move para o próximo LED (shift right)
    OUT PORTC, R16
    CALL delay     
	CALL delay 
	
	             ; Repete o processo para os próximos LEDs
    LDI R16,0b11111000                  ;LED3
    OUT PORTC, R16
    CALL delay     
	CALL delay 


    LDI R16,0b11110000                  ;LED4
    OUT PORTC, R16
    CALL delay     
	CALL delay 


    LDI R16,0b11100000                  ;LED5
    OUT PORTC, R16
    CALL delay     
	CALL delay 
	

    LDI R16,0b11000000               ;LED6
    OUT PORTC, R16
    CALL delay     
	CALL delay 
	

    LDI R16,0b10000000               ;LED7
    OUT PORTC, R16
    CALL delay     
	CALL delay 
	

	LDI R16,0b00000000               ;LED8
    OUT PORTC, R16
    CALL delay     
	CALL delay 
	CALL delay

	IN r17,PINA
	CPI r17,0b11011111
	BREQ SEQUENCIAOFF

    RJMP SEQUENCIALEDSOFF         
                 


SEQUENCIALEDSOFF:

	

    LDI R16, 0b10000000      ; Carrega o valor inicial de desligamento (D8)
    OUT PORTC, R16               ; Desliga o LED D8 (1 é desligado)
    CALL delay   
	
	
	              ; Chama o delay de 1 segundo
    LDI R16, 0b11000000                   ; Move para o LED anterior (shift left)
    OUT PORTC, R16
    CALL delay 
	
	
	                ; Repete o processo para os LEDs anteriores
    LDI R16, 0b11100000             ;LED3
    OUT PORTC, R16
    CALL delay
	
	

    LDI R16, 0b11110000             ;LED4
    OUT PORTC, R16
    CALL delay

	
    LDI R16, 0b11111000              ;LED5
    OUT PORTC, R16
    CALL delay
	
	

    LDI R16, 0b11111100            ;LED6
    OUT PORTC, R16
    CALL delay
	

    LDI R16, 0b11111110             ;LED7
    OUT PORTC, R16
    CALL delay



	LDI R16, 0b11111111             ;LED7
    OUT PORTC, R16

    RJMP LOOP 



SEQUENCIAOFF:
    LDI R16, 0b11111111          ; Desliga todos os LEDs 
    OUT PORTC, R16
    RJMP LOOP                     ; Volta para o loop principal




	
delay:	push r18
		push r19
		push r20

		ldi r20,220
ciclo0:	ldi r19,160
ciclo1:	ldi r18,151
ciclo2:	dec r18
	brne ciclo2


	dec r19
	brne ciclo1


	dec r20
	brne ciclo0

	pop r20
	pop r19
	pop r18
             
			
			    
   RET 

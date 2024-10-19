.equ ledsw1 = 0b00000000
.equ ledsw2 = 0b10101010
.equ ledsw3 = 0b01010101
.equ ledsw4 = 0b11100111
.equ ledsw6 = 0b11111111
.equ sw1 = 0
.equ sw2 = 1
.equ sw3 = 2
.equ sw4 = 3
.equ sw6 = 5

.cseg
.org 0

main:
    clr r16
    ldi r16, 0b00000000		; Configura os pinos de entrada
    out DDRA, r16		; Configura todos os pinos como entrada
    ldi r16, 0b11111111		; Configurar os pinos de saída
    out DDRC, r16
    out PORTC, r16		; Desliga todos os LEDs inicialmente 

loop:
    sbis PINA, sw1		; Se SW1 estiver pressionado executa a linha seguinte no código
    rjmp ligartodosleds
    sbis PINA, sw2		; Se SW2 estiver pressionado executa a linha seguinte no código
    rjmp ligarledssw2
    sbis PINA, sw3		; Se SW3 estiver pressionado executa a linha seguinte no código
    rjmp ligarledssw3
    sbis PINA, sw4		; Se SW4 estiver pressionado executa a linha seguinte no código
    rjmp ligarledssw4
    sbis PINA, sw6		; Se SW6 estiver pressionado executa a linha seguinte no código
    rjmp ligarledssw6
    rjmp loop

ligartodosleds:
    ldi r16, ledsw1
    out PORTC, r16		; Liga todos os LEDs
    rjmp loop

ligarledssw2:
    ldi r16, ledsw2
    out PORTC, r16		; Liga todos os LEDs do SW2
    rjmp loop

ligarledssw3:
    ldi r16, ledsw3
    out PORTC, r16		; Liga todos os LEDs do SW3
    rjmp loop

ligarledssw4:
    ldi r16, ledsw4
    out PORTC, r16		; Liga todos os LEDs do SW4
    rjmp loop

ligarledssw6:
    ldi r16, ledsw6
    out PORTC, r16		; Liga todos os LEDs do SW6
    rjmp loop

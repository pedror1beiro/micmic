.include<m128def.inc>
.EQU LEDSW1 = 0b00000000; referente à primeira tabela
.EQU LEDSw2 = 0b10101010
.EQU LEDSW3 = 0b01010101
.EQU LEDSW4 = 0b11100111
.EQU LEDSW6 = 0b11111111 
.EQU SW1 = 0; referente às saídas dos sw's    definidas as posições dos switches (interruptores) no registrador de entrada do microcontrolador (PINA)
.EQU SW2 = 1
.EQU SW3 = 2
.EQU SW4 = 3
.EQU SW6 = 5

.CSEG; indica o início do segmento de código
.ORG 0; define que o código começará no endereço 0 da memória


MAIN:

	CLR R16

	LDI R16, 0b00000000; configura os pinos de entrada
	OUT DDRA, R16;  configurados todos os pinos como entradas

	LDI R16, 0b11111111; configura os portas de saida
	OUT DDRC, R16
	OUT PORTC, R16; desliga todos os LEDs inicialmente

LOOP:

	SBIS PINA, SW1; se o bit for 0 nao salta
	JMP LIGARTODOSLEDS
	SBIS PINA, SW2
	JMP LIGARLEDSSW2
	SBIS PINA, SW3
	JMP LIGARLEDSSW3
	SBIS PINA, SW4
	JMP LIGARLEDSSW4
	SBIS PINA, SW6
	JMP LIGARLEDSSW6
	JMP LOOP


LIGARTODOSLEDS:
	LDI R16, LEDSW1
	OUT PORTC, R16
	JMP LOOP


LIGARLEDSSW2:
	LDI R16, LEDSW2
	OUT PORTC, R16
	JMP LOOP


LIGARLEDSSW3:
	LDI R16, LEDSW3
	OUT PORTC, R16
	JMP LOOP

LIGARLEDSSW4:
	LDI R16, LEDSW4
	OUT PORTC, R16
	JMP LOOP

LIGARLEDSSW6:
	LDI R16, LEDSW6
	OUT PORTC, R16
	JMP LOOP


.def temp = r16
.def cnt_int = r17
.def temp_int = r18
.def num_caps = r19
.def caps = r10

.cseg
.org 0x00                      ; Vetor de Reset
    jmp init
.org 0x1E
	jmp int_tc0

.org 0x46                      ; In?cio do c?digo principal

setseg:
.db 0b11111111,0b10001000, 0b10000011, 0b11000110, 0b10100001, 0b10000110, 0b10001110, 0b11000010, 0b10001001, 0b11111001, 0b11100001, 0b10001001, 0b11000111, 0b10101010, 0b10101011, 0b11000000, 0b10001100, 0b10011000, 0b10101111, 0b10010010, 0b10000111, 0b11000001, 0b10001001, 0b10100100



init:
		 ldi r16, 0b11111111        ; Configura PORTC (Display) como sa?da
    out DDRC, r16
    out PORTC, r16             ; Desliga todos os segmentos do display

    ldi r16,0b11000000
	out ddrd,r16			//portD sw's + escolha disp - entrada + saida
	out portd,r16

	; Configura o stack pointer
    ldi r24, low(RAMEND)
    out SPL, r24
    ldi r25, high(RAMEND)
    out SPH, r25

		ldi temp, 77                      ; Temporização base de 5ms (70)
        out OCR0, temp

        ldi cnt_int, 40                   ; Contador de 200ms
		ldi num_caps,0

        ldi temp, 0b00001111              ; TC0 em modo CTC, prescaler 1024, OC0 off
        out TCCR0, temp

        in r16, TIMSK                     ; Enable da interrupção do TC0 (CTC)
        ori r16, 0b00000010
        out TIMSK, r16

        sei                               ; Enable global das interrupções

		

sw1:
	in r21, PIND
    cpi r21, 0b11111110        ; Verifica se SW1 foi pressionado
    brne sw1

 ciclo:
	brtc ciclo
	clt

	inc num_caps
	cpi num_caps,23
	ldi num_caps, 0				//zerar numcaps se chegar a 23

	call display


    in r21, PIND
    cpi r21, 0b11111101        ; Verifica se SW2 foi pressionado
    breq piscar
	

rjmp ciclo


display:



ldi zh, high(setseg<<1)		//aponta Z para o endereco do espaco de memoria alocado para a tabela de 7seg.
ldi zl, low(setseg<<1)		//indicando ao compilador que tem de fazer shift a esq. do valor do endereco
add zl,num_caps 			//incrementa zl com o valor pretendido a mostrar

lpm r16,z
out portc, r16			//faz print para o display


ret




piscar:

	ldi temp, 77                      ; Temporização base de 5ms (70)
    out OCR0, temp
    ldi cnt_int, 100                   ; Contador de 200ms
	ldi temp, 0b00001111              ; TC0 em modo CTC, prescaler 1024, OC0 off
    out TCCR0, temp
	ldi caps,0
pisca1:
	in r21, PIND
    cpi r21, 0b11111101        ; Verifica se SW2 foi pressionado
    breq continua_ciclo

	brtc pisca1
	clt
	com r16
	out PORTC, r16

	inc caps
	cpi caps,15
	rjmp parar_piscar

	rjmp pisca1

	parar_piscar:
    ldi r16, 0b00001111         ; Configura TC0 para modo CTC, prescaler 1024, OC0 off
    out TCCR0, r16              ; Desativa o temporizador para parar o piscar
    ldi r16, 0xFF               ; Desativa todos os segmentos (padrão de desligado)
    out PORTC, r16              ; Limpa o display
    
	

    ; Carrega a letra atual no display sem piscar
    ldi zl, low(setseg<<1)      ; Aponta Z para o início da tabela de caracteres
    ldi zh, high(setseg<<1)
    add zl, num_caps            ; Incrementa Z pelo valor de num_caps (posição da letra)
    lpm r16, z                  ; Lê o caractere correspondente
    out PORTC, r16              ; Mostra o caractere fixo no display
    
    ret                         ; Retorna ao programa principal


	continua_ciclo:
    call display

    in r21, PIND
    cpi r21, 0b11111101          ; Verifica se SW2 foi pressionado
    breq piscar

    rjmp ciclo


int_tc0:
	in		temp_int,SREG
	dec		cnt_int
	brne	f_int
	ldi		cnt_int,40
	out		SREG,temp_int
	set		
	reti

f_int:
	out		SREG,temp_int
	reti




desligar:
    ldi r16, 0xFF              ; Desliga todos os segmentos do display
    out PORTC, r16

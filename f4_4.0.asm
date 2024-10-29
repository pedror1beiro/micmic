.def temp = r16
.def cnt_int = r17
.def temp_int = r18
.def num_caps = r19
.def aux = r20
.def caps = r25
.cseg
.org 0x00                      ; Vetor de Reset
    jmp init
.org 0x1E
	jmp int_tc0

.org 0x46                      ; In?cio do c?digo principal

setseg:
.db 0b11111111,0b10001000, 0b10000011, 0b11000110, 0b10100001, 0b10000110, 0b10001110, 0b11000010, 0b10001001, 0b11111001, 0b11100001, 0b10001001, 0b11000111, 0b10101010, 0b10101011, 0b11000000, 0b10001100, 0b10011000, 0b10101111, 0b10010010, 0b10000111, 0b11000001, 0b10001001, 0b10100100



init:
ldi r16, 0b11111111        ; Configura PORTC (Display) como saida
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

	ldi num_caps,0

//TEMPORIZADOR
	ldi temp, 77                      ; Temporização base de 5ms (70)
    out OCR0, temp

    ldi cnt_int, 40                   ; Contador de 200ms
		

    ldi temp, 0b00001111              ; TC0 em modo CTC, prescaler 1024, OC0 off
    out TCCR0, temp

    in r16, TIMSK                     ; Enable da interrupção do TC0 (CTC)
    ori r16, 0b00000010
    out TIMSK, r16
    sei                               ; Enable global das interrupções

main:
call sw1

roleta:
	brtc roleta
	clt				//inciar flag

	inc num_caps
	cpi num_caps,23
	breq zerarcaps
	
	call display

	in r21, PIND
    cpi r21, 0b11111101        ; Verifica se SW2 foi pressionado
    breq piscar
	
rjmp roleta

zerarcaps:
ldi num_caps, 0				//zerar numcaps se chegar a 23
rjmp roleta

display:
ldi zh, high(setseg<<1)		//aponta Z para o endereco do espaco de memoria alocado para a tabela de 7seg.
ldi zl, low(setseg<<1)		//indicando ao compilador que tem de fazer shift a esq. do valor do endereco
add zl,num_caps 			//incrementa zl com o valor pretendido a mostrar

lpm r16,z
out portc, r16			//faz print para o display
mov aux, r16

ret

piscar:
call int_tc03s
pisca1:
	brtc pisca1
	clt
	in r21, PIND
    cpi r21, 0b11111101        ; Verifica se SW2 foi pressionado
    breq continua_ciclo 

	
	cp r16, aux
	breq apaga
	mov r16, aux
	out PORTC, r16
	inc caps
	cpi caps,6  //500ms x 6  = 3segundos
	breq parar_piscar 

	rjmp pisca1

apaga:
	ldi r16, 0b11111111
	out portc, r16
	rjmp pisca1

continua_ciclo:
	mov r16, aux
	out portc, r16

	call int_tc0  // volta ao timer original

    rjmp roleta



sw1:
sbis PIND, 0         ; Verifica se o bit 5 está limpo (palete presente)
  ret
  rjmp sw1


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

int_tc03s:
	in		temp_int,SREG
	dec		cnt_int
	brne	f_int
	ldi		cnt_int,100    //500ms
	out		SREG,temp_int
	set		
	reti

parar_piscar:
mov r16,aux
out portc, r16
jmp fim


fim:
rjmp fim
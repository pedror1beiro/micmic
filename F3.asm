.def valorpeca = r18
.def aux = r21


.cseg
.org 0x00
    rjmp main             ; Início do programa, salta para a rotina main

; Tabela para display de 7 segmentos (valores 0-9)
setseg: .db 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90

main:
	ldi valorpeca, 0
    ldi r16, 0b11111111
    out DDRA, r16         ; Define o PortA como saída (para LEDs e display)
	out porta,r16
    ldi r16,0b11000000
	out ddrd,r16			//portD sw's + escolha disp - entrada + saida
	out portd,r16
	ldi r16, 0b11111111
	out DDRC, r16
	out portc,r16
    ; Inicializa o stack pointer (SP)
    ldi r16, 0xFF
    out SPL, r16          
    ldi r16, 0x10
    out SPH, r16          

   ldi r16,0b11111110		//ligar motor(led1)
	out porta,r16       ; Liga o motor (LED) inicialmente
	ldi r16,0xC0				//display 0
	out portc,r16

ciclo:
	call SP
	call parar_motor
	call sw0

	//call SC
	call SC 
rjmp ciclo



parar_motor:
    //cbi PORTA, 5          ; Desliga o motor (desativa LED no PA5) e ligar VE
	ldi r16,0b11111111
	out porta, r16
ret


sw0:
sbic PIND, 0; Verifica se o switch PD1 está pressionado
rjmp sw1
call delay
sbic PIND, 0; Verifica se o switch PD1 está pressionado
rjmp sw1	          
    ldi valorpeca, 2            ; Se estiver, seleciona 2 peças
	call mostrar_pecas   ; Atualiza o display de 7 segmentos com o número de peças
	call VEon
ret

sw1:
sbic PIND, 1          ; Verifica se o switch PD2 está pressionado
 rjmp sw2  
 call delay
 sbic PIND, 1          ; Verifica se o switch PD2 está pressionado
 rjmp sw2
    ldi valorpeca, 4            ; Se estiver, seleciona 4 peças
	call mostrar_pecas   ; Atualiza o display de 7 segmentos com o número de peças
	call VEon
ret

sw2:
sbic PIND, 2          ; Verifica se o switch PD3 está pressionado
rjmp sw0
call delay
sbic PIND, 2          ; Verifica se o switch PD2 está pressionado
 rjmp sw2   
    ldi valorpeca, 6            ; Se estiver, seleciona 6 peças
	call mostrar_pecas   ; Atualiza o display de 7 segmentos com o número de peças
	call VEon
ret

mostrar_pecas:

	cpi valorpeca, 0            ; Compara o valor de r18 (número de peças) com 0
	breq d0
    cpi valorpeca, 1
	breq d1
    cpi valorpeca, 2
    breq d2
    cpi valorpeca, 3
    breq d3
    cpi valorpeca, 4
    breq d4
    cpi valorpeca, 5
    breq d5
    cpi valorpeca, 6
    breq d6
	ret
	d0:
	    ldi r16, 0xC0         ; Valor para mostrar "0" no display de 7 segmentos               ; Se for igual a 0, vai para d0
		rjmp fim
	d1:
		ldi r16, 0xF9         ; Valor para mostrar "1"
		rjmp fim
	d2:
	   ldi r16, 0xA4         ; Valor para mostrar "2"
	  rjmp fim
	d3:
	  ldi r16, 0xB0         ; Valor para mostrar "3"
	  rjmp fim
	d4:
	  ldi r16, 0x99         ; Valor para mostrar "4"
	 rjmp fim
	d5:
	  ldi r16, 0x92         ; Valor para mostrar "5"
	  rjmp fim
	d6:
		ldi r16, 0x82         ; Valor para mostrar "6"
		rjmp fim
//display
fim:
	out PORTC, r16        ; Envia o valor para o display (PortC)
   // pop r16
	ret

VEon:
	ldi r16,0b01111111
	out porta,r16
	ret


vaiembora:
ldi r16,0xC0				//display 0
	out portc,r16

ldi r16,0b11111110
	out porta,r16
ret




SC:
sbis PIND, 4
	rjmp SCpress
	ldi aux,1
	rjmp SC


SP:
sbis PIND, 5         ; Verifica se o bit 5 está limpo (palete presente)
  ret
  rjmp SP


SCpress:
	cpi aux, 0
		breq SC
		ldi aux,0
		dec valorpeca
		breq vaiembora
		call mostrar_pecas	
		rjmp SCpress	


		delay: 
push r18                                            // guarda na memoria valor de registo r18
push r19                                            // guarda na memoria valor de registo r19
push r20                                            // guarda na memoria valor de registo r20
ldi r20, 1                                                    
ciclodelay0:
ldi r19, 150                                       
ciclodelay1:
ldi r18, 70                                      
ciclodelay2:
dec r18
brne ciclodelay2
dec r19
brne ciclodelay1
dec r20
brne ciclodelay0
dec r16                                             // decresce r16 para o ciclo de delay
pop r20                                             // recupera da memoria valor de registo r20
pop r19                                             // recupera da memoria valor de registo r19
pop r18                                             // recupera da memoria valor de registo r18
ret

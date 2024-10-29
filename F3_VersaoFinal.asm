

.cseg
.org 0x00
    rjmp main             ; Início do programa, salta para a rotina main

; Tabela para display de 7 segmentos (valores 0-9)
setseg: .db 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90

main:
	ldi r18, 0
    ldi r16, 0b11111111
    out DDRA, r16         ; Define o PortA como saída (para LEDs e display)
    ldi r16,0b11000000
	out ddrd,r16			//portD sw's + escolha disp - entrada + saida
	out portd,r16
	ldi r16, 0b11111111
	out DDRC, r16
    ; Inicializa o stack pointer (SP)
    ldi r16, 0xFF
    out SPL, r16          
    ldi r16, 0x10
    out SPH, r16          

   ldi r16,0b11111110		//ligar motor(led1)
	out porta,r16       ; Liga o motor (LED) inicialmente
	ldi r16,0xC0				//display 0
	out portc,r16


loop:
    ; Verifica se o sensor SP detecta uma palete (bit PD0)
    sbis PIND, 5          ; Verifica se o bit 5 está limpo (palete presente)
    call parar_motor      ; Se estiver, para o motor (LED)
rjmp loop

pecas:
    ; Seleciona o número de peças a transferir
    rcall selecionar_pecas

    ; Transfere as peças selecionadas
    rcall transferir_pecas


parar_motor:
    cbi PORTA, 5          ; Desliga o motor (desativa LED no PA5)
	ldi r16,0b11111111
	out porta, r16
    rjmp pecas


selecionar_pecas:
    ; Verifica cada switch para determinar o número de peças
    sbis PIND, 0          ; Verifica se o switch PD1 está pressionado
    ldi r18, 2            ; Se estiver, seleciona 2 peças

    sbis PIND, 1          ; Verifica se o switch PD2 está pressionado
    ldi r18, 4            ; Se estiver, seleciona 4 peças

    sbis PIND, 2          ; Verifica se o switch PD3 está pressionado
    ldi r18, 6            ; Se estiver, seleciona 6 peças

    ldi r19, 0            ; Inicializa a contagem de peças para 0
    rcall mostrar_pecas   ; Atualiza o display de 7 segmentos com o número de peças
    ret

; Função para transferir as peças
transferir_pecas:
    sbi PORTA, 7          ; Abre a válvula VE (LED no PA6)
    rcall mostrar_pecas   ; Mostra o número inicial de peças no display

transfer_loop:
    sbis PIND, 4          ; Espera pelo sensor SC 
    rcall delay           ; Introduz um atraso para evitar múltiplos sinais

    inc r19               ; Incrementa a contagem de peças transferidas
    cp r19, r18           ; Compara a contagem com o número de peças selecionado
    brne transfer_loop    ; Continua se ainda não transferiu todas as peças

    cbi PORTA, 7          ; Fecha a válvula VE (desliga o LED no PA6)
    ret

; Função para mostrar o número de peças no display de 7 segmentos
mostrar_pecas:
    push r16              

    cpi r18, 0            ; Compara o valor de r18 (número de peças) com 0
    breq d0               ; Se for igual a 0, vai para d0
    cpi r18, 1
    breq d1
    cpi r18, 2
    breq d2
    cpi r18, 3
    breq d3
    cpi r18, 4
    breq d4
    cpi r18, 5
    breq d5
    cpi r18, 6
    breq d6
    ret                   ; Sai da função se nenhuma condição for satisfeita

d0:
    ldi r16, 0xC0         ; Valor para mostrar "0" no display de 7 segmentos
    rjmp displayup
d1:
    ldi r16, 0xF9         ; Valor para mostrar "1"
    rjmp displayup
d2:
    ldi r16, 0xA4         ; Valor para mostrar "2"
    rjmp displayup
d3:
    ldi r16, 0xB0         ; Valor para mostrar "3"
    rjmp displayup
d4:
    ldi r16, 0x99         ; Valor para mostrar "4"
    rjmp displayup
d5:
    ldi r16, 0x92         ; Valor para mostrar "5"
    rjmp displayup
d6:
    ldi r16, 0x82         ; Valor para mostrar "6"

displayup:
    out PORTC, r16        ; Envia o valor para o display (PortC)
    pop r16               ; Restaura o conteúdo original de r16
    ret

; Função de delay para evitar múltiplos sinais
delay:
    push r18
    push r19
    push r20

    ldi r20, 18       ; Inicializa o valor Z do delay
    ldi r19, 20       ; Inicializa o valor Y do delay
    ldi r18, 30       ; Inicializa o valor X do delay

ciclo0:
    mov r25, r20
ciclo1:
    mov r26, r19
ciclo2:
    dec r18
    brne ciclo2       ; Se r18 ainda não for zero, continua

    dec r19
    brne ciclo1       ; Se r19 ainda não for zero, continua

    dec r20
    brne ciclo0       ; Se r20 ainda não for zero, continua

    pop r20           ; Restaura os registos
    pop r19
    pop r18
    ret

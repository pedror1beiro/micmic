.def temp = r16
.def cnt_int = r17
.def temp_int = r18
.def num_caps = r19
.def aux = r20
.def caps = r25
.def tempo_total = r23       ; Contador para controlar o tempo total de 3 segundos

.cseg
.org 0x00                      ; Vetor de Reset
    jmp init
.org 0x1E                      ; Endereço de interrupção para o Timer 0
    jmp int_tc0

.org 0x46                      ; Início do código principal

setseg:
.db 0b11111111, 0b10001000, 0b10000011, 0b11000110, 0b10100001, 0b10000110, 0b10001110, 0b10010000, 0b10001011, 0b11111001, 0b11100001, 0b11000111, 0b11001000, 0b10101011, 0b11000000, 0b10001100, 0b10011000, 0b10101111, 0b10010010, 0b10000111, 0b11100011, 0b11000001, 0b10001001,0b10100100


init:
    ; Configuração inicial dos ports e interrupções
    ldi r16, 0b11111111        ; Configura PORTC (Display) como saída
    out DDRC, r16
    out PORTC, r16             ; Desliga todos os segmentos do display

    ldi r16, 0b11000000        ; Configura PORTD para sw's + escolha disp
    out DDRD, r16
    out PORTD, r16

    ; Configuração do stack pointer
    ldi r24, low(RAMEND)
    out SPL, r24
    ldi r25, high(RAMEND)
    out SPH, r25

    ; Inicializações dos contadores
    ldi num_caps, 0

    ; Configuração do temporizador para 5ms
    ldi temp, 77               ; Temporização base de 5ms
    out OCR0, temp

    ldi cnt_int, 40            ; Contador para 200ms

    ldi temp, 0b00001111       ; TC0 em modo CTC, prescaler 1024, OC0 off
    out TCCR0, temp

    ; Ativar interrupção do TC0
    in r16, TIMSK
    ori r16, 0b00000010
    out TIMSK, r16
    sei                        ; Habilitar interrupções globais

main:
    call sw1                   ; Verifica se há presença de palete

roleta:
    brtc roleta                ; Espera até que o temporizador altere a flag
    clt                        ; Limpa a flag do temporizador

    inc num_caps               ; Incrementa o contador de letras
    cpi num_caps, 23           ; Verifica se chegou ao limite de letras
    breq zerarcaps

    call display               ; Atualiza o display com a letra atual

    in r21, PIND
    cpi r21, 0b11111101        ; Verifica se SW2 foi pressionado
    breq piscar                ; Inicia o ciclo de piscar se pressionado

    rjmp roleta                ; Continua a roleta

zerarcaps:
    ldi num_caps, 0            ; Reinicia o contador se atingir o limite
    rjmp roleta

display:
    ; Carrega o valor do segmento para exibir a letra correta
    ldi zh, high(setseg<<1)     
    ldi zl, low(setseg<<1)
    add zl, num_caps           

    lpm r16, z                 ; Lê o valor do segmento para exibir
    out PORTC, r16             ; Envia o valor ao display
    mov aux, r16               ; Guarda o valor atual no auxiliar

    ret

piscar:
    call int_tc03s             ; Inicia temporizador de 500ms para piscar
    clr tempo_total            ; Zera o contador para 3 segundos

pisca_loop:
    brtc pisca_loop            ; Espera pelo temporizador de 500ms
    clt                        ; Limpa a flag do temporizador
    
    inc tempo_total            ; Incrementa o contador para verificar os 3 segundos
    
    cpi tempo_total, 15         ; Verifica se atingiu 3 segundos
    breq parar_piscar          ; Se sim, para de piscar e fixa a letra
    
    in r21, PIND
    cpi r21, 0b11111101        ; Verifica se SW2 foi pressionado novamente
    breq continuar_ciclo       ; Volta ao ciclo principal se pressionado
    
    cp r16, aux
    breq apaga                 ; Alterna entre apagar e exibir
    mov r16, aux
    out PORTC, r16
    inc caps
    rjmp pisca_loop            ; Volta a piscar enquanto tempo < 3 segundos

apaga:
    ldi r16, 0b11111111        ; Apaga o display
    out PORTC, r16
    rjmp pisca_loop

parar_piscar:
    mov r16, aux               ; Fixa a última letra exibida no display
    out PORTC, r16
    jmp fim                    ; Fim do ciclo de piscar

continuar_ciclo:
    mov r16, aux
    out PORTC, r16

    call int_tc0               ; Restaura o temporizador original
    rjmp roleta                ; Volta ao loop da roleta

sw1:
    sbis PIND, 0               
    ret
    rjmp sw1

int_tc0:
    in temp_int, SREG
    dec cnt_int
    brne f_int
    ldi cnt_int, 40            ; Restaura o contador para 200ms
    out SREG, temp_int
    set                        ; Seta a flag para reiniciar a roleta
    reti

f_int:
    out SREG, temp_int
    reti

int_tc03s:
    in temp_int, SREG
    dec cnt_int
    brne f_int
    ldi cnt_int, 125           ; Temporização de 500ms para piscar
    out SREG, temp_int
    set                        ; Seta a flag para piscar
    reti

fim:
    rjmp fim                   ; Ciclo final do programa

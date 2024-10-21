.def letter_index = r16        ; Registro para armazenar o índice da letra atual
.def blink_flag = r17          ; Registro para armazenar o estado de piscar
.def delay_counter = r18       ; Registro para contagem de delay

.cseg
.org 0x00                      ; Vetor de Reset
    jmp init

.org 0x46                      ; Início do código principal

;=====================
; Tabela de Segmentos para as Letras (setseg)
;=====================
setseg: 
    setseg: 
    .db 0b01110111, 0b01111100, 0b00111001, 0b01011110, 0b01111001, 0b01110001, 0b00111101, 0b01110110
    .db 0b00000110, 0b00011110, 0b01110110, 0b00111000, 0b01010101, 0b01010100, 0b00111111, 0b01110011
    .db 0b01100111, 0b01010000, 0b01101101, 0b01111000, 0b00111110, 0b00101110, 0b01011110, 0b01110110
    .db 0b01101110, 0b01011011

    ; Correspondente aos caracteres de A até Z no display de 7 segmentos

init:
    ldi r16, 0b11111111        ; Configura PORTC (Display) como saída
    out DDRC, r16
    out PORTC, r16             ; Desliga todos os segmentos do display

    ldi r16, 0b11111100        ; Configura PORTD (Switches) como entrada
    out DDRD, r16

    ldi letter_index, 0        ; Inicia a roleta na letra "A" (índice 0)
    clr blink_flag             ; Inicialmente, o piscar está desativado

    ; Configura o stack pointer
    ldi r24, low(RAMEND)
    out SPL, r24
    ldi r25, high(RAMEND)
    out SPH, r25

main_loop:
    sbic PIND, 0               ; Verifica se SW1 (Start) foi pressionado
    rjmp start_roulette

    sbic PIND, 1               ; Verifica se SW2 (Stop) foi pressionado
    rjmp stop_and_blink

    rjmp main_loop

start_roulette:
    ; Mostra as letras de A até Z no display a cada 200ms
    call display_letter
    call delay_200ms

    ; Incrementa o índice da letra
    inc letter_index
    cpi letter_index, 26        ; Se passar da letra Z (índice 25), reinicia para A (índice 0)
    brlo main_loop
    clr letter_index
    rjmp main_loop

stop_and_blink:
    ; Pisca a letra atual durante 3 segundos, com frequência de 1 Hz
    ldi delay_counter, 6        ; Piscar por 3 segundos (6 ciclos de 500ms)
blink_loop:
    sbic PIND, 1               ; Verifica se SW2 (Stop) foi pressionado novamente
    rjmp resume_roulette

    com blink_flag             ; Inverte o estado de piscar
    breq turn_off_display
    call display_letter        ; Liga o display
    rjmp blink_delay

turn_off_display:
    ldi r16, 0xFF              ; Desliga todos os segmentos do display
    out PORTC, r16

blink_delay:
    call delay_500ms           ; Atraso de 500ms para controlar o piscar
    dec delay_counter
    brne blink_loop            ; Continua piscando até que 3 segundos passem
    clr blink_flag
    rjmp main_loop

resume_roulette:
    clr blink_flag
    rjmp main_loop

;=====================
; Funções Auxiliares
;=====================

display_letter:
    ldi ZL, low(setseg)        ; Carrega a parte baixa do endereço da tabela setseg no registrador ZL
    ldi ZH, high(setseg)       ; Carrega a parte alta do endereço da tabela setseg no registrador ZH
    add ZL, letter_index       ; Adiciona o índice da letra ao registrador ZL para buscar a letra correta
    ld r24, Z                  ; Carrega o valor da tabela no registrador r24
    out PORTC, r24             ; Envia o valor para o display
    ret

delay_200ms:
    push r19                   ; Guarda o valor de r19
    push r20                   ; Guarda o valor de r20
    push r21                   ; Guarda o valor de r21
    ldi r20, 100                                                    
ciclodelay0:
    ldi r19, 110                                       
ciclodelay1:
    ldi r18, 96                                      
ciclodelay2:
    dec r18
    brne ciclodelay2
    dec r19
    brne ciclodelay1
    dec r20
    brne ciclodelay0
    pop r21                   ; Recupera o valor de r21
    pop r20                   ; Recupera o valor de r20
    pop r19                   ; Recupera o valor de r19
    ret

delay_500ms:
    push r19                   ; Guarda o valor de r19
    push r20                   ; Guarda o valor de r20
    push r21                   ; Guarda o valor de r21
    ldi r20, 200                                                    
ciclodelay3:
    ldi r19, 199                                       
ciclodelay4:
    ldi r18, 66                                      
ciclodelay5:
    dec r18
    brne ciclodelay5
    dec r19
    brne ciclodelay4
    dec r20
    brne ciclodelay3
    pop r21                   ; Recupera o valor de r21
    pop r20                   ; Recupera o valor de r20
    pop r19                   ; Recupera o valor de r19
    ret
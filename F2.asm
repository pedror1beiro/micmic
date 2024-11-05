.CSEG
.ORG 0                          ; Início do código no endereço 0
jmp init                       ; Jump para a inicialização

.cseg
.ORG 0x46                      ; A partir da posição 46 da memória é onde o código será inserido

init:
    ldi r16, 0b11111111        ; Configura PORTC como saída (LEDs)
    out DDRC, r16              ; Define todos os pinos como saída
    out PORTC, r16             ; Desliga todos os LEDs

    ldi r16, 0b00000000        ; Configura PORTA como entrada (switch)
    out DDRA, r16

    ; Código para iniciar o Stack Pointer
    ldi r16, 0xFF
    out SPL, r16
    ldi r16, 0x10
    out SPH, r16

loop:
    in r16, PINA
    cpi r16, 0b11111110        ; Verifica se SW1 foi pressionado
    breq sequenciar

    call sw6

    ; Se nenhum switch foi pressionado, continua no loop
    rjmp loop                  



sequenciar:
    ; Ligar LEDs de D1 a D8 (2s de delay)
    ldi r25, 200               ; z do delay
    ldi r26, 244               ; y do delay
    ldi r27, 218               ; x do delay

    ; Liga LEDs de D1 a D8
    ldi r16, 0b11111110        ; D1 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b11111100        ; D2 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b11111000        ; D3 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b11110000        ; D4 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b11100000        ; D5 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b11000000        ; D6 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b10000000        ; D7 ligado
    out PORTC, r16
    call delay
    ldi r16, 0b00000000        ; D8 ligado
    out PORTC, r16
    call delay

    ; Espera 3 segundos após todos os LEDs acesos(3s de delay)
    ldi r25, 250               ; z do delay
    ldi r26, 250               ; y do delay
    ldi r27, 255               ; x do delay
    call delay

    ; Desligar LEDs de D8 a D1 (1s de delay)
    ldi r25, 148               ; z do delay
    ldi r26, 180               ; y do delay 
    ldi r27, 200               ; x do delay

    ldi r16, 0b10000000        ; D8 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11000000        ; D7 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11100000        ; D6 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11110000        ; D5 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11111000        ; D4 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11111100        ; D3 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11111110        ; D2 desligado
    out PORTC, r16
    call delay
    ldi r16, 0b11111111        ; D1 desligado
    out PORTC, r16
    call delay

    rjmp loop                  ; Volta para o loop principal

desligar:
    ldi r16, 0b11111111        ; Desliga todos os LEDs
    out PORTC, r16
    rjmp loop                  ; Volta para o loop principal

sw6:
	
	sbis PINA,5        ; Verifica se SW6 foi pressionado
    rjmp desligar
	ret

delay:
    push r18
    push r19
    push r20

    mov r20, r25               
ciclo0:
    mov r19, r26               
ciclo1:
    mov r18, r27
	call sw6    /////verificar sw6               
ciclo2:
    dec r18
    brne ciclo2

    dec r19
    brne ciclo1

    dec r20
    brne ciclo0

    pop r20                    ; Repoe os valores dos registos que estavam antes de entrar na stack
    pop r19
    pop r18
    ret

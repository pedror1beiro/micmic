/*
.equ ADCSRA, 0x26     ; Endere�o do registrador ADCSRA
.equ ADCH, 0x25       ; Endere�o do registrador ADCH

.global ler_ADC        ; Torna a fun��o vis�vel para o linker
.func ler_ADC          ; Marca o in�cio da fun��o

ler_ADC:
    ; Inicia a convers�o ADC
    lds r16, ADCSRA     ; Carrega o valor do registrador ADCSRA
    ori r16, 0x40       ; Seta o bit ADSC (0x40 equivale a 1 << 6, inicia a convers�o)
    sts ADCSRA, r16     ; Escreve o valor atualizado em ADCSRA

wait_adc:
    lds r16, ADCSRA     ; L� novamente o valor de ADCSRA
    sbrs r16, 6         ; Verifica o bit ADSC (se est� limpo, convers�o finalizada)
    rjmp wait_adc       ; Se ADSC ainda est� ativo, continua esperando

    ; Leitura do resultado (ADCH - 8 bits mais significativos)
    lds r16, ADCH       ; L� o valor de ADCH (resultado da convers�o)

    ; Retorna o valor em r16
    mov r24, r16        ; Move o resultado para r24 (registrador de retorno padr�o)
    ret                 ; Retorna ao chamador

ret
*/

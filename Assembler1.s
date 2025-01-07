/*
.equ ADCSRA, 0x26     ; Endereço do registrador ADCSRA
.equ ADCH, 0x25       ; Endereço do registrador ADCH

.global ler_ADC        ; Torna a função visível para o linker
.func ler_ADC          ; Marca o início da função

ler_ADC:
    ; Inicia a conversão ADC
    lds r16, ADCSRA     ; Carrega o valor do registrador ADCSRA
    ori r16, 0x40       ; Seta o bit ADSC (0x40 equivale a 1 << 6, inicia a conversão)
    sts ADCSRA, r16     ; Escreve o valor atualizado em ADCSRA

wait_adc:
    lds r16, ADCSRA     ; Lê novamente o valor de ADCSRA
    sbrs r16, 6         ; Verifica o bit ADSC (se está limpo, conversão finalizada)
    rjmp wait_adc       ; Se ADSC ainda está ativo, continua esperando

    ; Leitura do resultado (ADCH - 8 bits mais significativos)
    lds r16, ADCH       ; Lê o valor de ADCH (resultado da conversão)

    ; Retorna o valor em r16
    mov r24, r16        ; Move o resultado para r24 (registrador de retorno padrão)
    ret                 ; Retorna ao chamador

ret
*/

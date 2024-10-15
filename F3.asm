/*2DA_T1_1131158_Modified.asm
 */ 

 .include<m128def.inc>

.def	regtemp = r16		//define palavra regtemp como sendo o registo r16
.def	status_flag = r17	//registo utilizado para guardar flags de eventos
.def	num_caps = r18		//regista numero de capsulas presentes na maquina
.def	max_caps = r19		//regista o numero maximo de capsulas permitidos na maquina
.def	min_lim = r20		//regista o numero de capsulas presentes na maquina (aquando de VE on) a partil do qual ja se aceitam novas capsulas
.equ	limit_sw6	= 2		//variaveis para facilitar a escrita e leitura do codigo
.equ	limit_sw4 = 1		//correspondentes a sw's
.equ	limit_sw2 = 0
.equ	sw_add = 4
.equ	sw_remove = 5
.equ	led_limit6 = 2		//corespondentes a led's			
.equ	led_limit4 = 1
.equ	led_limit2 = 0
.equ	led_ve = 7   
.equ	empty_flag = 0		//flag indicativo de que o tambor da maquina se encontra vazio
//.equ	add_caps = 5

.cseg
.org	0x00				//vetor de reset com jump para a main			
	jmp	main
.cseg						
.org	0x46				//comeca a escrever no espaco de memoria de programa 0x46
setseg: .dd	0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90	//guarda na memoria de programa a tabela para disp 7seg.
																//atribuindo o nome ao espaco de memoria
main:
//CODIGO PARA INICIAR O STACK POINTER
	ldi r16, 0xFF
	out SPL, r16
	ldi r16, 0x10
	out SPH, r16
call init_ports


	loop:
	//verifica sw de limitadores
	//verifica sw de incrementar/decrementar capsulas
	check_limits:
	sbis pind,limit_sw6		//verifica se foi pressionado o sw para limitar n de capsulas a 6.
	call check_sw6
	sbis pind,limit_sw4		//verifica se foi pressionado o sw para limitar n de capsulas a 4.
	call check_sw4
	sbis pind,limit_sw2		//verifica se foi pressionado o sw para limitar n de capsulas a 2.
	call check_sw2
	sbis pind,sw_add		//verifica se foi pressionado o sw para acrescentar capsulas
	call add_caps
	sbis pind,sw_remove		//verifica se foi pressionado o sw para retirar capsulas
	call remove_caps
	rjmp loop				//caso nao seja pressionado qualquer sw, retorna ao inicio das verificacoes


	
;==========
;FUNCAO DE DEFINICAO DE PORTOS E ATRIBUICAO DE VALORES DEFAULT
;==========
init_ports:
ldi regtemp,0b11111111		//Set All Bits in Register como 1
out	ddra,regtemp			//portA led's - saidas
							//led's acendem a valor logico zero
out ddrc,regtemp			//portC display 7seg. - saidas
ldi regtemp,0b11000000
out ddrd,regtemp			//portD sw's + escolha disp - entrada + saida
out portd,regtemp			
							 
;defaults
//definindo o led 1,2 e 3 como indicativos do limite de capsulas imposto
ldi regtemp,0b00000100		//inicia o VE(LED8) ligado e o limitador de capsulas a 6 (led3)
out porta,regtemp
ldi max_caps,6				//inicia com o limite de 6 capsulas
ldi min_lim,1				
lpm regtemp,z				//carrega primeiro valor da tabela
out portc,regtemp			//e inicia disp com valor zero
ldi	num_caps,0				//inicia a maquina com 0 capsulas
ret

;==========
;FUNCOES PARA ADICIONAR E RETIRAR CAPSULAS
;==========
add_caps:
rcall delay					//chama delay, para despistar ruido/perturabacoes no sw e garantir que o mesmo esta realmente a ser pressionado
sbic pind,sw_add			//verifica novamente sw, se tiver ocorrido um falso acionamento do sw, regressa aos testes dos sw's
ret
	perform_add:
	sbis pina,led_ve			//verifica se o numero de capsulas existentes na maquina permite colocar mais capsulas.
	ret
	inc num_caps				//incrementa o numero de capsulas na maquina
	rcall print_disp			//envia para disp de 7 seg. numero de capsulas presentes na maquina
	cp num_caps,max_caps		//verifca se atingiu limite maximo de capsulas permitidas
	brne no_add				//se afirmacao falsa, regressa a testes de sw's
	sbi porta,led_ve			//em caso afirmativo, contrario ativa valvula VE
	no_add:
	ret						//regressa ao teste sw's
remove_caps:
rcall delay					//chama delay, para despistar ruido/perturabacoes no sw e garantir que o mesmo esta realmente a ser pressionado
sbic pind,sw_remove			//verifica novamente sw, se tiver ocorrido um falso assionamento do sw, regressa aos testes dos sw's	
ret
	perform_remove:
	sbrc status_flag,empty_flag	//verifica se o deposito se encontra vazio			
	ret						//em caso afirmativo regressa a testes de sw's, sem retirar capsulas
	dec num_caps				//decrementa o numero de capsulas
	rcall print_disp			//envia para disp de 7 seg. numero de capsulas presentes na maquina
	cp num_caps,min_lim		//verifica se o numero de capsulas ja permite que seja desativada a valvula VE
	brge no_add				//se afirmacao falsa, regressa a testes de sw's.
	sbis pina,led_ve			//caso a valvula ja estiver desativa, regressa aos testes de sw's
	ret
	sbi porta,led_ve			//caso contratio, activa a valvula
	cpi num_caps,0				//verificar se o tambor das capsulas ficou vazio
	brne no_add				//se nao, regressa a testes dos sw's.
	sbr status_flag,empty_flag	//em caso afirmativo, ativa a flag correspondente.
	ret
;==========
;FUNCOES PARA ATRIBUICAO DE LIMITES AO NUMERO DE CAPSULAS PERMITIDAS NA MAQUINA
;==========
check_sw6:
call delay					//chama delay, para despistar ruido/perturabacoes no sw e garantir que o mesmo esta realmente a ser pressionado
sbic pind,limit_sw6
ret
	set_limit6:
	ldi max_caps,6			//atribui o numero limite de capsulas como 6.
	ldi min_lim,3			//atribui o valor minimo de capsulas presentes para manter VE ativada.
	ret
check_sw4:
call delay					//chama delay, para despistar ruido/perturabacoes no sw e garantir que o mesmo esta realmente a ser pressionado
sbic pind,limit_sw4
ret
	perform_sw4:
	cpi num_caps,5			//verifica se axistem no maximo 6 capsulas na maquina
	brlt set_limit4			//em caso afirmativo inicia mudanca de limite para 4
	ret						//caso contrario retorna aos testes de sw's.
	set_limit4:
	ldi max_caps,4			//define numero maximo de capsulas como sendo 4.
	ldi min_lim,2			//define numero minimo de capsulas presentes para manter VE.	
	ret
check_sw2:
call delay					//chama delay, para despistar ruido/perturabacoes no sw e garantir que o mesmo esta realmente a ser pressionado
sbic pind,limit_sw2
ret
	perform_sw2:
	cpi num_caps,3			//verifica se axistem no maximo 2 capsulas na maquina
	brlt set_limit2			//em caso afirmativo salta para a mudanca de limite de capsulas.
	ret						//caso contratio regressa a testes de sw's.
	set_limit2:
	ldi max_caps,2			//define valor maximo de capsulas como sendo 2.
	ldi min_lim,1			//define valor a baixo do qual se pode dessativar VE.
	ret
;==========
;FUNCAO DE ENVIO DE VALORES PARA O DISPLAY DE 7 SEGUEMENTOS
;==========
print_disp:
push num_caps
ldi zh, high(setseg<<1)		//aponta Z para o endereco do espaco de memoria alocado para a tabela de 7seg.
ldi zl, low(setseg<<1)		//indicando ao compilador que tem de fazer shift a esq. do valor do endereco
add num_caps, zl			//incrementa zl com o valor pretendido a mostrar
ld num_caps, z				//carrega o valor apontado
out portc, num_caps			//faz print para o display
pop num_caps
ret
;==========
;FUNCAO DE DELAY (EXECUCAO DE TAREFAS DE FORMA A "QUEIMAR" TEMPO)
;==========
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


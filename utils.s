.text
##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
# $a1 = quantidade de caractesres iniciais a pular
# Retorno:
# $v0 = Endereco pra primeira posicao onde comeca o argumento
# $v1 = Se o argumento foi encontrado $v1 = 1, do contrario $v1 = 0
pegar_argumento:
    addiu	$sp, $sp, -12	# Ajuste da pilha
    sw      $s0, 0($sp)
    sw      $s1, 4($sp)
    sw      $ra, 8($sp)

    move    $s0, $a0        # $s0 = &vetorDeCaracteres[0]
    
    move    $s1, $a1        # $s1 = $a1 Quantidades de caracteres a pular

    #Nesse ponto $a0 ainda e o &vetorDeCaracteres[0]
    jal     quantidade_de_caracteres
    move 	$t1, $v0		# $t1 <- quantidade de caracteres em &vetorDeCaracteres[0]

    li      $v0, 1
    move 	$v1, $v0		# $v1 = $v0 = 1; Se der tudo certo retornaremos com $v1 = 1

    # Checamos se a quantidade de caracteres a pular eh menor que a quantidade total de caracteres
    ble		$t1, $s1, qtd_caracteres_a_pular_eh_maior_que_string	# if $t1 <= $s1 then fim_pega_argumento

    add	    $s0, $s0, $s1	# $s0 = $s0 + $s1 (&vetorDeCaracteres[0] + caracteres_a_pular)
    move 	$v0, $s0		# $v0 = $s0
    j       fim_pega_argumento

    qtd_caracteres_a_pular_eh_maior_que_string:
    li      $v1, 0          # Flag pra avisar que deu erro

    fim_pega_argumento:
    lw      $s0, 0($sp)
    lw      $s1, 4($sp)
    lw      $ra, 8($sp)
    addiu	$sp, $sp, 12	# Ajuste da pilha
    jr      $ra
##### FIM pegar_argumento #####


##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
# Retorno:
# $v0 = quantidade de caracteres
quantidade_de_caracteres:
    la      $t0, 0($a0) # $t0 = Posicao inicial do vetor de caracteres
    li      $v0, 0 # $t4 = contador de caracteres
    laco_contador:
        lb      $t1, 0($t0) # Pega a letra e joga em $t1
        li      $t2, '\0' # $t2 = '\0' caractere final
        beq		$t1, $t2, fim_contador	# if $t1    == $t1 then target
        addi    $t0, $t0, 1 # $t0 = Proxima posicao no vetor de caracteres
        addi    $v0, $v0, 1 # Incrementa o contador $v0
        j       laco_contador
    fim_contador:
    jr $ra
##### FIM quantidade_de_caracteres #####


##############
# Argumentos:
# $a0 = &nomedoarquivo[0]
# Retorno:
# $v0 = descritor do arquivo /se $v0 = 0 -> end_of_file/ se $v0 < 0 -> deu erro
open_file:
    # $a0 = posicao inicial do vetor do nome do arquivo
    # Abrir para a leitura
    li      $v0, 13       # system call para abrir arquivo
    li      $a1, 0        # Abrir para a leitura (flags sao 0: ler, 1: escrever)
    li      $a2, 0        # mode eh ignorado
    syscall               # abrir o arquivo (file descriptor retornado em $v0)
    jr      $ra    
##### FIM open_file #####


##############
# Argumentos:
# $a0 = file descriptor
# $a1 = endereco do buffer
# $a2 = maximo numero de caracteres a ler
# Retorno:
# $v0 = contem o numero de caracteres lidos 
# (0 se end-of-file, negativo if error).
read_file:
    li      $v0, 14        # $v0 = 14  
    syscall                # chamada ao sistema para ler o arquivo
    jr      $ra
##### FIM read_file #####


##############
# Argumentos:
# $a0 = &buffer[0]
# $a1 = &memoria[0]
# $a2 = Quantidade de 4-bytes a serem inseridos 
write_buffer_on_memory:
    addiu   $sp, $sp, -32
    sw      $s0, 0($sp)
    sw      $s1, 4($sp)
    sw      $s2, 8($sp)
    sw      $s3, 12($sp)
    sw      $s4, 16($sp)
    sw      $s5, 20($sp)
    sw      $s6, 24($sp)
    sw      $ra, 28($sp)

    move 	$s0, $a0		# $s0 = $a0 (&buffer[0])
    move 	$s1, $a1		# $s1 = $a1 (&memoria[0])
    move 	$s2, $a2		# $s2 = Quantidade bytes_a_serem_inseridos
    li 	    $s5, 3		    # $s5 = 3 (contador para inserir a 4-bytes word na memoria)
    move 	$s6, $zero		# $s6 = 0 (contadorNormalizado para buscar do buffer)

    li		$s6, 0		    # $s6 = 0 (Buffer-Word-Count)
    li      $s3, 0          # (Word-Count) Contador para saber qual byte estamos escrevendo na memoria

    inicio_laco:
        bgt		$s3, $s2, fim_laco	# if contador > bytes_a_serem_inseridos then fim_laco (CONTADOR SEMPRE SERA MULTIPLO DE 4)
        
        add     $t1, $s0, $s6       # $t1 = &buffer[0] + Buffer-Word-Count  === &buffer[Buffer-Word-Count]
        
        lw      $s4, 0($t1)         # $s4 = buffer[contador] - Dado a escrever na memoria
        
        inicio_laco_insere_word_na_memoria:
            blt		$s5, $zero, fim_laco_insere	# if $s5(Word-Count) < 0 then fim_laco_insere
            
            move 	$a0, $s4		    # $a0 = $s4 (4-byte word a ser escrita)
            move    $a1, $s5            # $a1 = Word-Count (Index da posicao que queremos pegar)
            jal     get_specific_byte

            add     $a0, $s1, $s3       # $a0 = &memoria[0] + contador === &memoria[contador] - Endereco a escrever o dado
            move    $a1, $v0            # $v0 from get_specific_byte
            jal     escreve_memoria
            addi    $s5, $s5, -1         # Word-Count-1
            addi    $s3, $s3, 1         # contador+1 -- Vai pra proxima posicao na memoria
            j       inicio_laco_insere_word_na_memoria
        fim_laco_insere:
        addi	$s6, $s6, 4			# $s6 = $s6 + 4
        li      $s5, 3              # Word-Count = 3
        j       inicio_laco

    fim_laco:

    lw      $s0, 0($sp)
    lw      $s1, 4($sp)
    lw      $s2, 8($sp)
    lw      $s3, 12($sp)
    lw      $s4, 16($sp)
    lw      $s5, 20($sp)
    lw      $s6, 24($sp)
    lw      $ra, 28($sp)
    addiu   $sp, $sp, 32
    jr      $ra
##### FIM write_buffer_on_memory #####


##############
# Argumentos:
# $a0 = 4-bytes word
# $a1 = index a ser retornado
# Ex.: $a0 = 0x27BD9705 e $a1 = 2. O retorno sera 0x00000097
# Este procedimento pega apenas o byte na posicao desejada
# Retorno:
# $v0 = O byte na posicao $a1 (index)
get_specific_byte:
    move 	$t0, $a0		# $t0 = $a0 (4-bytes word)
    li      $t1, 0xFF000000 # Mascara inicial
    sll     $a1, $a1, 3     # $a1 = index*8
    srlv    $t1, $t1, $a1   # Desloca a mascara index*8 posicoes para a direita
    and     $v0, $t0, $t1   # $v0 = (4-bytes word)&(marcara deslocada) - BITWISE AND 
    # (index)  (shift-right)
    # 0   -     6     = 32 - (0*8 + 8)
    # index_n   -     SHIFT = 32 - (index_n*8 + 8)
    # Precisamos deslocar o resultado de $v0 para direita seguindo a ideia acima
    # Neste ponto $a1 = index*8, portanto
    addi	$a1, $a1, 8			# $a1 = $a1 + 8 <-> (index_n*2 + 8)
    li      $t1, 32
    sub 	$t0, $t1, $a1			# $t0 = 32 - (index_n*8 + 8) -- Logo $t0 tem o valor que temos que deslocar
    srlv    $v0, $v0, $t0
    jr      $ra
##### FIM get_specific_byte #####


##############
# Argumentos:
# $a0 = Valor a ser extendido
# $a1 = index_bit_replicado (index do bit a ser replicado)
# Retorno:
# $v0 = Valor extendido
extend_signal:
    li		$t0, 0x00000001		# $t0 = 0x00000001 Mask_Extend
    sllv    $t0, $t0, $a1       # Desloca para a esquerda ate chegarmos no bit a ser replicado
    and     $t1, $a0, $t0       # $t1 = Value & Mask_Extend = 0 ou Valor diferente de zero
    
    beqz    $t1, valor_a_extender_eh_zero
    j       valor_a_extender_eh_um
    valor_a_extender_eh_zero:
        #Precisamos de uma nova Mask_Extend
        li		$t0, 0xFFFFFFFF
        li		$t2, 31		        # $t2 = 31
        sub		$t1, $t2, $a1		# $t1 = 31 - index_bit_replicado
        srlv    $t0, $t0, $t1       # Mask_Extend agora esta deslocada para setar como zero os
                                    # valores apos o index_bit_replicado
        and     $v0, $a0, $t0       # Aplica a mascara
        j       fim_extend_signal
    valor_a_extender_eh_um:
        #Precisamos de uma nova Mask_Extend
        li		$t0, 0xFFFFFFFF
        sllv    $t0, $t0, $a1       # Mask_Extend agora esta deslocada para setar como zero os
                                    # valores apos o index_bit_replicado
        or      $v0, $a0, $t0       # Aplica a mascara
        j       fim_extend_signal
    fim_extend_signal:
    jr		$ra					# jump to $ra
##### FIM extend_signal #####


##############
# Argumentos:
# $a0 = &buffer - Deve possuir pelo menos 11 posicoes para a string
# $a1 = numHex
# Retorno:
# $v0 = 1 se a conversao foi realizada com sucesso e 0 caso houver erro
convert_hex_2_string:
    addiu   $sp, $sp, -12
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)		# Bits a shiftar >>
    
	li 		$s1, 28			# $s1 = 28
    move    $s0, $a0        # $s0 <- Cursor de &buffer
    # Escrevemos 0x na mao
    li		$t0, '0'		# $t0 = '0'
    sb		$t0, 0($s0)		# buffer[0] = '0'

    add     $s0, $s0, 1
    li		$t0, 'x'		# $t0 = 'x'
    sb		$t0, 0($s0)		# buffer[1] = 'x'

    li		$t0, 0xF0000000	# $t0 = 0xF0000000 Byte_mask
    add     $s0, $s0, 1
    inicio_laco_convert_hex_2_string:

        beqz    $t0, fim_laco_convert_hex_2_string

        and     $t1, $a1, $t0   # $t1 <- numHex & Byte_Mask (Byte isolado)
		srlv	$t1, $t1, $s1	# Shiftar $t1 >> $s1_bytes
        li		$t2, 0xa		# $t2 = 0xa
        
        bge		$t1, $t2, h2s_eh_letra	# if $t1 >= 0xa then target
        
        li		$t2, '0'		# $t2 = '0'
        add		$t2, $t2, $t1   # $t2 = '0' + Byte isolado
        
        j		h2s_epilogo_laco # jump to h2s_epilogo_laco
        h2s_eh_letra:

        li		$t2, 'a'		# $t2 = 'a'
        subi    $t1, $t1, 0xa	# $t1 = $t1 - 0xa
        add		$t2, $t2, $t1   # $t2 = 'a' + Byte isolado    

        h2s_epilogo_laco:
        sb      $t2, 0($s0)     # buffer[i] = Letra correspondente ao byte isolado
        add     $s0, $s0, 1
        subi    $s1, $s1, 4
        srl     $t0, $t0, 4 	# Byte_mask
        j		inicio_laco_convert_hex_2_string # jump to inicio_laco_convert_hex_2_string
    fim_laco_convert_hex_2_string:
    li		$t2, '\0'		# $t2 = '\0'
    sb      $t2, 0($s0)      # buffer[end] = '\0'

    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    addiu   $sp, $sp, 12
    jr		$ra
##### FIM convert_hex_2_string #####

##############
# Argumentos:
# $a0 = &buffer - Deve possuir pelo menos 12 posicoes para a string
# $a1 = numDec
# Retorno:
# $v0 = 1 se a conversao foi realizada com sucesso e 0 caso houver erro
convert_dec_2_string:
    addiu   $sp, $sp, -16
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)		# Num a shiftar >>
    sw      $s2, 12($sp)	# Count of digits
    
    move 	$s1, $a1		# $s1 = $a1
    move 	$s2, $zero		# $s2 = $zero
    move    $s0, $a0        # $s0 <- Cursor de &buffer

    beqz    $s1, d2s_num_eh_zero # if $s1 == 0 then d2s_num_eh_zero
    j       d2s_num_nao_eh_zero

    d2s_num_eh_zero:
        li      $t2, '0'
        sb      $t2, 0($s0)
        li      $t2, '\0'
        sb      $t2, 1($s0)
        j		fim_laco_convert_dec_2_string   # jump to fim_laco_convert_dec_2_string
        
    d2s_num_nao_eh_zero:
    move    $t0, $s1
    d2s_count_size:
        beqz    $t0, d2s_count_size_end
        addi    $s2, $s2, 1
        li      $t1, 10
        div		$t0, $t0, $t1	    # $t0 / 10
        j       d2s_count_size
    d2s_count_size_end:

    
    
    li      $t2, '\0'
    add     $t0, $s0, $s2
    sb      $t2, 0($t0)     # buffer[0 + deslocamento]
    addi    $s2, $s2, -1

    inicio_laco_convert_dec_2_string:
        li     $t2, -1
        beq    $s2, $t2, fim_laco_convert_dec_2_string

        li      $t0, 10
        div		$s1, $s1, $t0	    # $s1 / $t10
        mfhi	$t1					# $t1 = $s1 mod 10 
        

        li		$t2, '0'		# $t2 = '0'
        add		$t2, $t2, $t1   # $t2 = '0' + num_isolado(atraves da divisao por 10)

        add     $t0, $s0, $s2
        sb      $t2, 0($t0)     # buffer[0 + deslocamento]
        addi    $s2, $s2, -1
        j		inicio_laco_convert_dec_2_string # jump to inicio_laco_convert_dec_2_string
    fim_laco_convert_dec_2_string:

    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    addiu   $sp, $sp, 16
    jr		$ra
##### FIM convert_dec_2_string #####


##############
# Argumentos:
# $a0 = Endereço real. Ex.: 0x10010080 (memoria de dados)
# Retorno:
# $v0 = Endereço virtual correspondente ao real. Ex.: 0x1001033c OU Zero em caso de erro
convert_real_address_2_virtual:
    addiu   $sp, $sp, -8
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)

    move    $s0, $a0 # Guardamos esse endereço pois utilizaremos

    move    $a0, $s0
    li      $a1, ei_memoria_dados
    li      $a2, ef_memoria_dados
    jal     pertence_segmento_memoria
    li      $t0, 1
    beq     $v0, $t0, cra2v_eh_memoria_dados # if $v0 == 1 then cra2v_eh_memoria_dados

    move    $a0, $s0
    li      $a1, ei_memoria_instrucoes
    li      $a2, ef_memoria_instrucoes
    jal     pertence_segmento_memoria
    li      $t0, 1
    beq     $v0, $t0, cra2v_eh_memoria_instrucoes # if $v0 == 1 then cra2v_eh_memoria_instrucoes

    move    $a0, $s0
    li      $a1, ei_memoria_pilha
    li      $a2, ef_memoria_pilha
    jal     pertence_segmento_memoria
    li      $t0, 1
    beq     $v0, $t0, cra2v_eh_memoria_pilha # if $v0 == 1 then cra2v_eh_memoria_pilha

    j       cra2v_erro # Se chegar aqui quer dizer que nao esta em nenhum dos intervalos citados, isso significa que temos algum erro

    cra2v_eh_memoria_dados:
        subi	$t0, $s0, ei_memoria_dados  # $t0 = Endereco_real - Endereco_real_base (Isso nos dara o deslocamento)
        la      $t1, memoria_dados          # $t1 = &memoria_dados
        addu    $v0, $t1, $t0               # $v0 = &memoria_dados + deslocamento
        j		cra2v_fim	                # jump to cra2v_fim
    cra2v_eh_memoria_instrucoes:
        subi	$t0, $s0, ei_memoria_instrucoes  # $t0 = Endereco_real - Endereco_real_base (Isso nos dara o deslocamento)
        la      $t1, memoria_instrucoes          # $t1 = &memoria_instrucoes
        addu    $v0, $t1, $t0                    # $v0 = &memoria_instrucoes + deslocamento
        j		cra2v_fim	                     # jump to cra2v_fim
    cra2v_eh_memoria_pilha:
        subi	$t0, $s0, ei_memoria_pilha  # $t0 = Endereco_real - Endereco_real_base (Isso nos dara o deslocamento)
        la      $t1, memoria_pilha       # $t1 = &memoria_pilha
        addu    $v0, $t1, $t0            # $v0 = &memoria_pilha + deslocamento
        j		cra2v_fim	             # jump to cra2v_fim
    cra2v_erro:
        li		$v0, 0		# $v0 = 0
        j		cra2v_fim	# jump to cra2v_fim
    cra2v_fim:

    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra
##### FIM convert_real_address_2_virtual #####

##############
# Este procedimento apenas imprime ' -> '
print_label_arrow:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)

    la		$a0, label_arrow
    jal     imprime_string

    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM print_label_arrow #####

##############
# Este procedimento apenas imprime '\n'
print_end_of_line:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)

    la		$a0, end_of_line
    jal     imprime_string

    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM print_end_of_line #####

##############
# Este procedimento apenas imprime '-----------\n'
print_line_separator:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)

    la		$a0, line_separator
    jal     imprime_string

    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM print_line_separator #####

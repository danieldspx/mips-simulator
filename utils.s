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
    move 	$s5, $zero		# $s5 = 0 (contador para inserir a 4-bytes word na memoria)

    li		$s6, 0		    # $s6 = 0 (Buffer-Word-Count)
    li      $s3, 0          # (Word-Count) Contador para saber qual byte estamos escrevendo na memoria
    sll     $s2, $s2, 2     # bytes_a_serem_inseridos*4 pois cada 4-bytes ocupam na realidade 16 bytes na memoria. 
                            # 1 byte para cada 4 bytes de espaco na memoria

    inicio_laco:
        bgt		$s3, $s2, fim_laco	# if contador > bytes_a_serem_inseridos then fim_laco (CONTADOR SEMPRE SERA MULTIPLO DE 4)
        
        add     $t1, $s0, $s6       # $t1 = &buffer[0] + Buffer-Word-Count  === &buffer[Buffer-Word-Count]
        
        lw      $s4, 0($t1)         # $s4 = buffer[contador] - Dado a escrever na memoria
        
        inicio_laco_insere_word_na_memoria:
            li      $t0, 4 
            bge		$s5, $t0, fim_laco_insere	# if $s5(Word-Count) >= 4 then fim_laco_insere
            
            move 	$a0, $s4		    # $a0 = $s4 (4-byte word a ser escrita)
            move    $a1, $s5            # $a1 = Word-Count (Index da posicao que queremos pegar)
            jal     get_specific_byte

            add     $a0, $s1, $s3       # $a0 = &memoria[0] + contador === &memoria[contador] - Endereco a escrever o dado
            move    $a1, $v0            # $v0 from get_specific_byte
            jal     escreve_memoria
            addi    $s5, $s5, 1         # Word-Count+1
            addi    $s3, $s3, 4         # contador+4 -- Vai pra proxima posicao na memoria
            j       inicio_laco_insere_word_na_memoria
        fim_laco_insere:
        addi	$s6, $s6, 4			# $s6 = $s6 + 4
        move    $s5, $zero          # Word-Count = 0
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
# $a0 = &Variable
# $a1 = index do bit a ser replicado
# Ex.: $a0 = 0x27BD9705 e $a1 = 2. O retorno sera 0x00000097
# Este procedimento pega apenas o byte na posicao desejada
# Retorno:
# $v0 = O byte na posicao $a1 (index)
extend_signal:
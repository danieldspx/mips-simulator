.data:
.align 2
error_msg_m: .asciiz "Erro ao executar comando M\n"
.text:
##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
executa_comando_m:
    # O que eu vou fazer eh, pegar a string
    # "0xbeefdead 10" e substituir o espaco por \0
    # usar a funcao e converte hex_str para int
    # depois usar a funcao de calcular o tamanho de uma string
    # ai ele vai me retornar o tamanho de "0xbeefdead"
    # vou usar a funcao que me retorna o argumento com um salto de strlen("0xbeefdead")
    # ai teremos "10", dai é so converter pra inteiro e depois mostrar
    addiu	$sp, $sp, -32
    sw		$ra, 0($sp)
    sw      $s0, 4($sp)     # &vetorDeCaracteres[0]
    sw      $s1, 8($sp)     # realAddress (Also, it is the memory adress)
    sw      $s2, 12($sp)    # numInt
    #hasConverted 16($sp)
    sw      $s3, 20($sp)    # virtualAddress
    sw      $s4, 24($sp)    # contador
    sw      $s5, 28($sp)    # wordOnMemory

    # $a0 = (&vetorDeCaracteres[0])
    li      $a1, 2          # caracteres a pular
    jal     pegar_argumento
    
    move 	$s0, $v0		# $s0 = $v0 (&vetorDeCaracteres[2])

    # Vamos procurar o ' ' e substituir por '\0'
    li		$t0, ' '
    move    $t2, $s0
    exc_m_inicio_laco:
        lb      $t1, 0($t2)
        beq		$t0, $t1, exc_m_fim_laco	# if $t0 == $t1 then exc_m_fim_laco
        beq		$zero, $t1, erro_comando_m
        addiu   $t2, $t2, 1
        j       exc_m_inicio_laco
    exc_m_fim_laco:
    sb		$zero, 0($t2)   # aqui colocamos o '\0' no lugar do ' '

    move    $a0, $s0
    la      $a1, 16($sp)    # hasConverted
    jal     converte_string_hexadecimal_para_decimal
    move    $s1, $v0
    lw      $t1, 16($sp)
    beq		$zero, $t1, erro_comando_m # if hasConverted == 0 then erro_comando_m

    move    $a0, $s0
    jal     quantidade_de_caracteres
    move    $t0, $v0        # Quantidade de caracteres a pular
    addi	$t0, $t0, 1		# $t0 = $t0 + 1 (Vamos pular um caractere a mais pois pularemos o '\0')
    
    addu   $s0, $s0, $t0    # Aqui pulamos ja para onde comeca o argumento inteiro

    move    $a0, $s0        # Endereco de onde comeca o argumento inteiro
    la      $a1, 16($sp)    # hasConverted
    jal     converte_string_decimal
    move    $s2, $v0
    lw      $t1, 16($sp)
    beq		$zero, $t1, erro_comando_m # if hasConverted == 0 then erro_comando_m

    move    $a0, $s1         # $a0 = realAddress
    jal     convert_real_address_2_virtual
    move    $s3, $v0        # $s3 = virtualAddress
    beq		$zero, $v0, erro_comando_m # if zero means that we have a error then erro_comando_m

    move    $s4, $zero      # contador = 0

    exc_m_inicio_laco_print:
        bge		$s4, $s2, exc_m_fim_laco_print	# if contador >= numInt then exc_m_fim_laco_print

        lw      $s5, 0($s3)             # $s5 = word from virtualAddres

        # Imprime o endereco em si. Ex.: 0x10010000
        la		$a0, buffer_general
        move 	$a1, $s1		 
        jal		convert_hex_2_string 
        la		$a0, buffer_general
        jal     imprime_string

        jal     print_label_arrow
        
        # Imprime o valor que esta na memoria (em hexadecimal)
        la		$a0, buffer_general
        move 	$a1, $s5
        jal		convert_hex_2_string 
        la		$a0, buffer_general
        jal     imprime_string

        jal     print_end_of_line

        addi	$s4, $s4, 1			    # $s4 = $s4 + 1
        addi	$s3, $s3, 4			    # $s3 = virtualAddress + 4
        addi	$s1, $s1, 4			    # $s1 = realAddress + 4
        j		exc_m_inicio_laco_print
    exc_m_fim_laco_print:

    jal     print_line_separator

    j		exc_m_fim

    erro_comando_m:
    # Imprimir na tela mensagem de erro
    la		$t0, error_msg_m 
    move    $a0, $t0        # $a0 = $t0 (Endereço da mensgem de erro)
    jal     imprime_string  # imprime string

    exc_m_fim:
    
    lw		$ra, 0($sp) 
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    lw      $s3, 20($sp)
    lw      $s4, 24($sp)
    lw      $s5, 28($sp)
    addiu   $sp, $sp, 32
    jr      $ra
##### FIM executa_comando_m #####
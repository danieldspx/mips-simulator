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
    addiu	$sp, $sp, -20
    sw		$ra, 0($sp)
    sw      $s0, 4($sp)     # &vetorDeCaracteres[0]
    sw      $s1, 8($sp)     # numHex (Also, it is the memory)
    sw      $s2, 12($sp)    # numInt
    #hasConverted 16($sp)
    
    move 	$s0, $a0		# $s0 = $a0 (&vetorDeCaracteres[0])

    # Vamos procurar o ' ' e substituir por '\0'
    li		$t0, ' '
    exc_m_inicio_laco:
        lb      $t1, 0($a0)
        beq		$t0, $t1, exc_m_fim_laco	# if $t0 == $t1 then exc_m_fim_laco
        beq		$zero, $t1, erro_comando_m
        addiu   $a0, $a0, 1
        j       exc_m_inicio_laco
    exc_m_fim_laco:
    sb		$zer0, 0($a0)   # aqui colocamos o '\0' no lugar do ' '

    move    $a0, $s0
    la      $a1, 16($sp)    # hasConverted
    jal     converte_string_hexadecimal_para_decimal
    move    $s1, $v0
    lw      $t1, 16($sp)
    beq		$zero, $t1, erro_comando_m # if hasConverted == 0 then erro_comando_m

    move    $a0, $s0
    jal     quantidade_de_caracteres
    move    $a0, $s0
    move    $a1, $v0 # Quantidade de caracteres a pular
    addi	$a1, $a1, 1			# $a1 = $a1 + 1 (Vamos pular um caractere a mais pois pularemos o '\0')
    jal     pegar_argumento
    ##AQUI CONVERTEMOS PARA INT, o argumento vai estar em $v0
    
    j		exc_m_fim
    erro_comando_m:
    # Imprimir na tela mensagem de erro
    la		$t0, error_msg_m 
    move    $a0, $t0        # $a0 = $t0 (Endereço da mensgem de erro)
    jal     imprime_string  # imprime string

    exc_m_fim:
    
    lw		$ra, 0($sp) 
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)
    addiu   $sp, $sp, 20
    jr      $ra
##### FIM executa_comando_m #####
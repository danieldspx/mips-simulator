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
    move 	$v0, $s0		# $v0 = $t1
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
    la $t0, 0($a0) # $t0 = Posicao inicial do vetor de caracteres
    li $v0, 0 # $t4 = contador de caracteres
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
        

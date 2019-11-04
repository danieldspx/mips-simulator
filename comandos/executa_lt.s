##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
executa_comando_lt:
    addiu   $sp, $sp, -8
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)

    li      $a1, 3          # (3) Caracteres a pular
    # Neste ponto $a0 = &vetorDeCaracteres[0], entao mantemos, pois
    # pegar_argumento espera em $a0 isso
    jal     pegar_argumento
    move 	$s0, $v0		# $s0 <- Endereco para a primeira posicao onde comeca o argumento
    beqz    $v1, fim_comando_lt # Se $v1 == 0 Significa que nao foi possivel pegar o argumento

    #Imprimir na tela so pra teste mesmo
    move    $a0, $s0        # $a0 = $s0
    jal     imprime_string

    fim_comando_lt:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra
##### FIM executa_comando_lt #####
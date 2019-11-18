.text:
##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
executa_comando_r:
    addiu	$sp, $sp, -16
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)     # Contador
    #int hasConverted 12($sp)

    li      $a1, 2          # (2) Caracteres a pular
    # Neste ponto $a0 = &vetorDeCaracteres[0], entao mantemos, pois
    # pegar_argumento espera em $a0 isso
    jal     pegar_argumento
    move 	$s0, $v0		       # $s0 <- Endereco para a primeira posicao onde comeca o argumento
    beqz    $v1, fim_comando_r     # Se $v1 == 0 Significa que nao foi possivel pegar o argumento 
    #TODO: Adicionar mensagem de erro avisando que nao foi possivel pegar o argumento

    move 	$a0, $s0		       # $a0 <- Endereco para a primeira posicao onde comeca o argumento
    la		$t0, 12($sp)		   # $t0 <- Endereco de 8($sp)
    move	$a1, $t0               # $a1 <- &hasConverted
    jal     converte_string_decimal
    move    $s0, $v0               # $s0 = Numero de instrucoes a executar
    move 	$s1, $zero		       # Contador = 0

    lw		$t0, 12($sp)		   # $t0 <- hasConverted
    
    beqz    $t0, fim_comando_r     # Se $t0 == 0 entao fim_comando_r (houve erro na conversao)
    #TODO: Adicionar mensagem de erro de conversao 

    inicio_laco_r:
        bge		$s1, $s0, fim_laco_r	# if contador >= Numero de instrucoes a executar $ then fim_laco_r
        
        jal     fetch_execute_cycle

        addi	$s1, $s1, 1			# $s1 = $s1 + 1
        j		inicio_laco_r
    fim_laco_r:

    fim_comando_r:
    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    addiu	$sp, $sp, 16
    jr      $ra
##### FIM executa_comando_r #####
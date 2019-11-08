.data:
buffer_lt: .space 256
error_msg_lt: .asciiz "Erro ao executar comando LT\n"
success_msg_lt: .asciiz "Sucesso ao executar comando LT\n"
.text:
##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
executa_comando_lt:
    addiu   $sp, $sp, -12
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)

    li      $a1, 3          # (3) Caracteres a pular
    # Neste ponto $a0 = &vetorDeCaracteres[0], entao mantemos, pois
    # pegar_argumento espera em $a0 isso
    jal     pegar_argumento
    move 	$s0, $v0		        # $s0 <- Endereco para a primeira posicao onde comeca o argumento
    beqz    $v1, fim_comando_lt     # Se $v1 == 0 Significa que nao foi possivel pegar o argumento

    move    $a0, $s0
    jal		open_file           # jump to read_file and save position to $ra

    # Se o arquivo não foi aberto corretamente, throw error 
    blt		$v0, $zero, erro_comando_lt	# if $v0 < $t1 then erro_comando_lt

    move    $s1, $v0            # Salvamos o file descriptor em $s1
    move    $a0, $s1            # $a0 = File descriptor
    la      $a1, buffer_lt      # Carrega o buffer de caracteres
    addi    $a2, $zero, 256     # Maximo de caracteres a serem lidos
    jal     read_file           # Chamar funcao para ler aquivo

    la      $a0, buffer_lt
    la      $a1, memoria_instrucoes
    move    $a2, $v0            # $a2 = Quantidade de bytes a serem inseridos

    jal     write_buffer_on_memory

    la      $t0, buffer_lt
    li      $t1, 0x0
    sw      $t1, 0($t0) 

    # Imprimir na tela mensagem de sucesso
    la		$t0, success_msg_lt 
    move    $a0, $t0        # $a0 = $t0 (Endereço da mensgem de sucesso)
    jal     imprime_string  # imprime string

    j       fim_comando_lt

    erro_comando_lt:
    # Imprimir na tela mensagem de erro
    la		$t0, error_msg_lt 
    move    $a0, $t0        # $a0 = $t0 (Endereço da mensgem de erro)
    jal     imprime_string  # imprime string

    fim_comando_lt:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM executa_comando_lt #####

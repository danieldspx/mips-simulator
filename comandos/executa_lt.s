.data:
buffer: .space 1024
file_loc: .asciiz "text.bin"
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

    #Imprimir na tela so pra teste mesmo
    #move    $a0, $s0        # $a0 = $s0
    #jal     imprime_string

    #move    $a0, $s0
    la		$a0, file_loc	    # 
    jal		open_file           # jump to read_file and save position to $ra

    move    $s1, $v0            # Salvamos o file descriptor em $s1
    move    $a0, $s1            # $a0 = File descriptor
    la      $a1, buffer         # Carrega o buffer de caracteres
    addi    $a2, $zero, 1024    # Maximo de caracteres a serem lidos
    jal     read_file

    fim_comando_lt:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM executa_comando_lt #####
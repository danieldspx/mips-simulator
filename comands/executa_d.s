.data
entry_msg_d: .asciiz "\nRegistradores:\n"

.text
##############
# Argumentos:
# Nao ha argumentos
executa_comando_d:
    addiu   $sp, $sp, -8
    sw		$ra, 0($sp) 
    sw		$s0, 4($sp) # Contador Indice dos registradores

    # Imprimir na tela mensagem de erro
    la		$t0, entry_msg_d 
    move    $a0, $t0        # $a0 = $t0 (Endereço da mensgem de erro)
    jal     imprime_string  # imprime string

    move 	$s0, $zero		# $s0 = $zero

    excd_inicio_laco:
        li		$t1, 32		# $t1 = 32
        bge		$s0, $t1, excd_fim_laco	# if contadot >= 32 then excd_fim_laco
        
        move 	$a0, $s0		        # $a0 = Indice do registrador
        jal     leia_registrador
        move 	$a1, $v0		 
        la		$a0, buffer_general
        jal		convert_hex_2_string    # Converte Hex to String
        la		$a0, buffer_general
        jal     imprime_string          # imprime string
        addi	$s0, $s0, 1			# $s0 = $s0 + 1
        j		excd_inicio_laco
    excd_fim_laco: 

    lw		$ra, 0($sp) 
    lw		$s0, 4($sp)   
    addiu   $sp, $sp, 8
    jr		$ra					# jump to $ra
##### FIM executa_comando_d #####
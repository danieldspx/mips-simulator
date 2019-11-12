.text
.eqv    check_signal_mask    0x80000000
.eqv    invert_mask     0xFFFFFFFF
execute_addiu:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # addiu rt, rs, imm (Tipo I)
    la		$t0, IR_campo_rs    # $t0 <- &IR_campo_rs
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$t0, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)
    
    la		$t1, IR_campo_imm   # $t1 <- &IR_campo_imm
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato
   
    addu    $t2, $t0, $t1

    # epilogo_operacao
    la		$t0, IR_campo_rt    # $t0 <- &IR_campo_rt
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rt - indice do registrador rt
    
    move 	$a0, $t0
    move 	$a1, $t2		    # $a1 = Resultado da operacao
    jal		escreve_registrador	# jump to escreve_registrador and save position to $ra

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_addiu #####

execute_add:
    addiu   $sp, $sp, -12
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)

    # add rd, rs, rt
    la		$s0, IR_campo_rs    # $s0 <- &IR_campo_rs
    lw		$s0, 0($s0)		    # $s0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $s0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$s0, $v0		    # $s0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$s1, IR_campo_rt    # $s1 <- &IR_campo_rt
    lw		$s1, 0($s1)		    # $s1 <- Valor de IR_campo_rt - indice do registrador rt
    move 	$a0, $s1		    # $a0 = Valor de IR_campo_rt
    jal     leia_registrador
    move 	$s1, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rt nos indica)

    add		$t2, $s0, $s1		# $t2 = $s0 + $s1

    # epilogo_operacao
    la		$t0, IR_campo_rd    # $t0 <- &IR_campo_rd
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rd - indice do registrador rd
    
    move 	$a0, $t0
    move 	$a1, $t2		    # $a1 = Resultado da operacao
    jal		escreve_registrador	# jump to escreve_registrador and save position to $ra

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM execute_add #####


execute_addu:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # add rd, rs, rt
    la		$t0, IR_campo_rs    # $t0 <- &IR_campo_rs
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$t0, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$t1, IR_campo_rt    # $t0 <- &IR_campo_rt
    lw		$t1, 0($t1)		    # $t0 <- Valor de IR_campo_rt - indice do registrador rt
    move 	$a0, $t1		    # $a0 = Valor de IR_campo_rt
    jal     leia_registrador
    move 	$t1, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rt nos indica)

    addu	$t2, $t0, $t1		# $t2 = $t0 + $t1

    # epilogo_operacao
    la		$t0, IR_campo_rd    # $t0 <- &IR_campo_rd
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rd - indice do registrador rd
    
    move 	$a0, $t0
    move 	$a1, $t2		    # $a1 = Resultado da operacao
    jal		escreve_registrador	# jump to escreve_registrador and save position to $ra

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_addu #####

execute_syscall:
    addiu   $sp, $sp, -12
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)

    li		$a0, 4		# $a0 = 4 indice do registrador = $a0
    jal     leia_registrador
    move 	$s0, $v0    # $s0 = $v0 (valor de $a0 virtual)

    li		$a0, 5		# $a0 = 5 indice do registrador = $a1
    jal     leia_registrador
    move 	$s1, $v0    # $s0 = $v0 (valor de $a1 virtual)

    li		$a0, 2		# $a0 = 2 indice do registrador = $v0
    jal     leia_registrador

    # Restaura $a0 e $a1
    move 	$a0, $s0		# $a0 = $s0
    move 	$a1, $s1		# $a1 = $s1

    # Aqui o valor de $v0 ja eh o valor que estava no nosso $v0 virtual
    # Assim, basta fazer a chamada syscall
    syscall

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM execute_syscall #####

execute_sw:
    addiu   $sp, $sp, -12
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)

    # sw rt, address  | 0x2b | rs | rt | offset |
    la		$s0, IR_campo_rs    # $s0 <- &IR_campo_rs
    lw		$s0, 0($s0)		    # $s0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $s0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$s0, $v0		    # $s0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$s1, IR_campo_rt    # $s1 <- &IR_campo_rt
    lw		$s1, 0($s1)		    # $s1 <- Valor de IR_campo_rt - indice do registrador rt
    move 	$a0, $s1		    # $a0 = Valor de IR_campo_rt
    jal     leia_registrador
    move 	$s1, $v0		    # $s1 = $v0 (Valor que se encontra no registrador que o IR_campo_rt nos indica)

    la		$t2, IR_campo_imm   # $t2 <- &IR_campo_imm
    lw		$t2, 0($t2)		    # $t2 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato

    # Aplicamos o offset em rs (contem um endereco)
    addu    $s0, $s0, $t2       # Usamo so addu pois nao queremos overflow

    # Agora salvamos em memoria o valor de rt no endereco rs+offset = $s0
    move 	$a0, $s0		# $a0 = $s0 (Endereco de memoria que queremos escrever)
    move 	$a1, $s1		# $a1 = $s1 (Valor a ser gravado na memoria)
    jal     escreve_memoria

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM execute_sw #####

executa_addi:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # addi rt, rs, imm | 0x08 | rs | rt | imm |
    la		$t0, IR_campo_rs    # $t0 <- &IR_campo_rs
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$t0, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$t1, IR_campo_imm   # $t1 <- &IR_campo_imm
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato

    addi    $t2, $t0, $t1       # $t2 = rs + imm

    la		$t0, IR_campo_rt    # $t0 <- &IR_campo_rt
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rt - indice do registrador rt
    
    move 	$a0, $t0
    move 	$a1, $t2		    # $a1 = Resultado da operacao
    jal		escreve_registrador	# jump to escreve_registrador and save position to $ra

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM executa_addi #####
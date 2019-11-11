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

    epilogo_operacao:
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
    jr      $ra
##### FIM execute_add #####
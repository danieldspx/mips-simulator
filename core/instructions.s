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
   
    andi    $t3, $t1, check_signal_mask # Pegamos o MSB com essa mascara
    beqz    $t3, imm_eh_positivo    # if $t3 == 0 then imm_eh_positivo
    j       imm_eh_negativo         # else imm_eh_negativo

    # Agora faremos a operacao (addu ou subu) de $t0 e $t1 e salvaremos em $t2 para depois colocar em $rt
    imm_eh_positivo:
    addu    $t2, $t0, $t1       # Usei o addu porque estamos simulando o addiu, mas aqui o nosso imm esta em uma variavel
    j		epilogo_operacao	# jump to epilogo_operacao
    
    imm_eh_negativo:
    # Quer dizer que o nosso imm esta com extensao de sinal e eh negativo
    # portanto precisamos inverter e somar 1 para obter o valor positivo
    # e depois fazer a subtracao do mesmo
    xori    $t1, $t1, invert_mask   # Invertemos os bits
    addi	$t1, $t1, 1             # Somamos 1
    subu    $t2, $t0, $t1
    j		epilogo_operacao	    # jump to epilogo_operacao

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
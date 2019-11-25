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
    move 	$s1, $v0		    # $s1 = $v0 (Valor que se encontra no registrador que o IR_campo_rt nos indica)

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
    addiu   $sp, $sp, -8
    sw		$ra, 0($sp)
    sw      $s0, 4($sp)

    # addu rd, rs, rt
    la		$s0, IR_campo_rs    # $s0 <- &IR_campo_rs
    lw		$s0, 0($s0)		    # $s0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $s0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$s0, $v0		    # $s0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$t1, IR_campo_rt    # $t1 <- &IR_campo_rt
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_rt - indice do registrador rt
    move 	$a0, $t1		    # $a0 = Valor de IR_campo_rt
    jal     leia_registrador
    move 	$t1, $v0		    # $t1 = $v0 (Valor que se encontra no registrador que o IR_campo_rt nos indica)

    addu	$t2, $s0, $t1		# $t2 = $s0 + $t1

    # epilogo_operacao
    la		$t0, IR_campo_rd    # $t0 <- &IR_campo_rd
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rd - indice do registrador rd
    
    move 	$a0, $t0
    move 	$a1, $t2		    # $a1 = Resultado da operacao
    jal		escreve_registrador	# jump to escreve_registrador and save position to $ra

    lw		$ra, 0($sp)
    lw      $s0, 4($sp)
    addiu   $sp, $sp, 8
    jr      $ra
##### FIM execute_addu #####

execute_syscall:
    addiu   $sp, $sp, -16
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)
    sw		$s2, 12($sp)

    li		$a0, 4		# $a0 = 4 indice do registrador = $a0
    jal     leia_registrador
    move 	$s0, $v0    # $s0 = $v0 (valor de $a0 virtual)

    li		$a0, 5		# $a0 = 5 indice do registrador = $a1
    jal     leia_registrador
    move 	$s1, $v0    # $s1 = $v0 (valor de $a1 virtual)

    li		$a0, 2		# $a0 = 2 indice do registrador = $v0
    jal     leia_registrador
    move    $s2, $v0    # $s2 = $v0 (valor de $v0 virtual)

    li      $t0, 1
    beq		$v0, $t0, exsys_eh_print_int	# if $v0 == 1 then exsys_eh_print_int

    li      $t0, 4
    beq		$v0, $t0, exsys_eh_print_string	# if $v0 == 4 then exsys_eh_print_string

    j       exsys_fim
    
    exsys_eh_print_int:
        ## Por enquanto nao faz nada
        la		$a0, buffer_general
        move    $a1, $s0        # $a1 = Integer to print
        jal     convert_dec_2_string
        la		$a0, buffer_general
        jal     imprime_string  # imprime string no terminal
        j       exsys_fim
    exsys_eh_print_string:
        move    $a0, $s0    # $a0 = Endereco real
        jal     convert_real_address_2_virtual
        # Aqui $v0 eh o endereco virtual
        move    $s0, $v0    # $s0 = address of null-terminated string to print (virtual)
        move	$a0, $v0
        jal     imprime_string  # imprime string no terminal
        j       exsys_fim
    exsys_fim:
    # Restaura $a0, $a1 e $v0
    move 	$a0, $s0		# $a0 = $s0
    move 	$a1, $s1		# $a1 = $s1
    move 	$v0, $s2		# $a1 = $s1

    syscall

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    lw		$s2, 12($sp)
    addiu   $sp, $sp, 16
    jr      $ra
##### FIM execute_syscall #####

execute_sw:
    addiu   $sp, $sp, -16
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)
    sw		$s2, 12($sp)

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

    move    $s2, $zero          # contador = 0

    # Agora salvamos em memoria o valor de rt no endereco rs+offset = $s0
    laco_store_word_sw:
        li      $t0, 4
        bge		$s2, $t0, fim_laco_store_word_sw	# if contador >= 4 then fim_laco_store_word_sw
        
        move 	$a0, $s0		# $a0 = $s0 (Endereco de memoria que queremos escrever)
        move 	$a1, $s1		# $a1 = $s1 (Valor a ser gravado na memoria)
        jal     escreve_memoria

        srl     $s1, $s1, shift_1_byte      # word >> shift_1_byte
        
        addi	$s0, $s0, 1	        # Endereco da memoria+1
        addi	$s2, $s2, 1	        # contador+1
        j		laco_store_word_sw   # jump to laco_load_byte_lw
    fim_laco_store_word_sw:
    

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    lw		$s2, 12($sp)
    addiu   $sp, $sp, 16
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

    add    $t2, $t0, $t1       # $t2 = rs + imm

    la		$t0, IR_campo_rt    # $t0 <- &IR_campo_rt
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rt - indice do registrador rt
    
    move 	$a0, $t0
    move 	$a1, $t2		    # $a1 = Resultado da operacao
    jal		escreve_registrador	# jump to escreve_registrador and save position to $ra

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM executa_addi #####

execute_jal:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # jal target | 0x03 | imm |
    # Devemos lembrar que neste ponto o valor PC ja vale PC+4.
    # Logo a instrucao sendo executada esta em PC-4. Mas ta tudo certo, pois usamos PC+4 mesmo
    # Colocamos o valor de PC em $ra = $31
    la      $t0, PC             # $t0 <- &PC
    lw      $t0, 0($t0)         # $t0 <- Valor de PC
    li      $t1, 31
    move 	$a0, $t1		    # $a0 = Indice de $ra
    move 	$a1, $t0		    # $a0 = Valor de PC
    jal     escreve_registrador # Escrevemos no registrador $ra
    
    la      $t0, PC             # $t0 <- &PC
    lw      $t0, 0($t0)         # $t0 <- Valor de PC

    andi    $t0, $t0, 0xF0000000 # Isola os 4 primeiros bits de PC
    
    la		$t1, IR_campo_j     # $t1 <- &IR_campo_j
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_j - Aqui ja temos o valor imediato

    sll     $t1, $t1, 4         # imm << 4
    srl     $t1, $t1, 4         # imm >> 4
    sll     $t1, $t1, 2         # imm << 2 (Aqui estamos multiplicando por 4)
    or      $t2, $t1, $t0       # Append os 4-bit msb do PC+4 em imm
    
    la      $t0, PC             # $t0 <- &PC
    sw      $t2, 0($t0)         # Valor de PC = $t2 = Endereco do jump

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_jal #####

execute_lw:
    addiu   $sp, $sp, -16
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)
    sw		$s2, 12($sp)

    # lw rt, address | 0x23 | rs | rt | offset |
    la		$s0, IR_campo_rs    # $s0 <- &IR_campo_rs
    lw		$s0, 0($s0)		    # $s0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $s0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$s0, $v0		    # $s0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$t2, IR_campo_imm   # $t2 <- &IR_campo_imm
    lw		$t2, 0($t2)		    # $t2 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato

    # Aplicamos o offset em rs (contem um endereco)
    addu    $s0, $s0, $t2       # Usamo so addu pois nao queremos overflow

    move    $s1, $zero          # Inicializa $s1 (word) com zero para usar a operacao OR
    move    $s2, $zero          # Inicializa contador
    
    # Agora lemos da memoria o valor no endereco rs+offset = $s0
    laco_load_byte_lw:
        li      $t0, 4
        bge		$s2, $t0, fim_load_byte_lw	# if contador >= 4 then fim_load_byte_lw
        
        srl     $s1, $s1, shift_1_byte      # word >> shift_1_byte
        move 	$a0, $s0		    # $a0 = $s0 (Endereco de memoria que queremos ler)
        jal     leia_memoria
        sll     $v0, $v0, shift_3_byte # Byte lido << shift_3_byte
        or      $s1, $s1, $v0       # Colocamos um byte na word
        addi	$s0, $s0, 1	        # Endereco da memoria+1
        addi	$s2, $s2, 1	        # contador+1
        j		laco_load_byte_lw   # jump to laco_load_byte_lw
    fim_load_byte_lw:

    la		$t0, IR_campo_rt    # $t0 <- &IR_campo_rt
    lw		$t0, 0($t0)		    # $s1 <- Valor de IR_campo_rt - indice do registrador rt
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rt
    move 	$a1, $s1		    # $a0 = Word a ser escrita em rt
    jal     escreve_registrador # Escrevemos no registrador rt

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    lw		$s2, 12($sp)
    addiu   $sp, $sp, 16
    jr      $ra
##### FIM execute_lw #####

execute_lui:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # lui rt, imm (Ex.: lui $12, 0xdeadf123 -> $12 = 0xf1230000 )
    la		$t0, IR_campo_imm   # $t0 <- &IR_campo_imm
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato
    andi    $t0, $t0, 0x0000FFFF
    sll     $t0, $t0, shift_2_byte


    la		$t1, IR_campo_rt    # $t1 <- &IR_campo_rt
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_rt - indice do registrador rt
    
    move 	$a0, $t1		    # $a0 = Valor de IR_campo_rt
    move 	$a1, $t0		    # $a0 = Upper immediate Word a ser escrita em rt
    jal     escreve_registrador

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_lui #####

execute_bne:
    addiu   $sp, $sp, -12
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)

    # bne rs, rt, imm
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

    bne     $s0, $s1, execute_bne_should_branch
    j		execute_bne_fim				# jump to execute_bne_fim

    execute_bne_should_branch:
        la		$t0, IR_campo_imm   # $t0 <- &IR_campo_imm
        lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato
        sll     $t0, $t0, 2         # [O CERTO EH <<2 POIS AQUI CADA INSTRUCAO DISTA 4 POSICOES DA PROXIMA]

        la      $t1, PC             # $t1 <- &PC
        lw      $t1, 0($t1)         # $t1 <- Valor de PC

        addu    $t0, $t0, $t1       # $t0 <- (imm<<2)+(PC+4)

        la      $t1, PC             # $t1 <- &PC
        sw      $t0, 0($t1)         # $t0 -> Valor de PC
    execute_bne_fim:
    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM execute_bne #####

execute_ori:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # ori rt, rs, imm
    la		$t0, IR_campo_rs    # $t0 <- &IR_campo_rs
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$t0, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la		$t1, IR_campo_imm   # $t1 <- &IR_campo_imm
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_imm - Aqui ja temos o valor imediato

    or      $t2, $t0, $t1       # $t2 <- OR de rs e imm

    la		$t0, IR_campo_rt    # $t0 <- &IR_campo_rt
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rt - indice do registrador rt
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rt
    move 	$a1, $t2		    # $a0 = Valor a ser armazenado em rt
    jal     escreve_registrador

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_ori #####

execute_jr:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # jr rs | 0x00 | rs | 0 | 0x08 |
    la		$t0, IR_campo_rs    # $t0 <- &IR_campo_rs
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rs - indice do registrador rs
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rs
    jal     leia_registrador
    move 	$t0, $v0		    # $t0 = $v0 (Valor que se encontra no registrador que o IR_campo_rs nos indica)

    la      $t1, PC             # $t1 <- &PC
    sw      $t0, 0($t1)         # $t0 (Endereco no registrador rs) -> PC

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_jr #####

execute_j:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    # j target | 0x03 | imm |
    # Devemos lembrar que neste ponto o valor PC ja vale PC+4.
    # Logo a instrucao sendo executada esta em PC-4. Mas ta tudo certo, pois usamos PC+4 mesmo
    
    la      $t0, PC             # $t0 <- &PC
    lw      $t0, 0($t0)         # $t0 <- Valor de PC

    andi    $t0, $t0, 0xF0000000 # Isola os 4 primeiros bits de PC
    
    la		$t1, IR_campo_j     # $t1 <- &IR_campo_j
    lw		$t1, 0($t1)		    # $t1 <- Valor de IR_campo_j - Aqui ja temos o valor imediato
    
    sll     $t1, $t1, 4         # imm << 4
    srl     $t1, $t1, 4         # imm >> 4
    sll     $t1, $t1, 2         # imm << 2
    or      $t2, $t1, $t0       # Append os 4-bit msb do PC+4 em imm

    la      $t0, PC             # $t0 <- &PC
    sw      $t2, 0($t0)         # Valor de PC = $t2 = Endereco do jump

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM execute_j #####

execute_mul:
    addiu   $sp, $sp, -12
    sw		$ra, 0($sp)
    sw		$s0, 4($sp)
    sw		$s1, 8($sp)

    # mul rd, rs, rt
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

    mul		$t2, $s0, $s1		# $t2 = $s0 + $s1

    la      $t0, lo             # $t0 <- &lo
    sw      $t2, 0($t0)         # Resultado da multiplicacao -> lo

    la		$t0, IR_campo_rd    # $t0 <- &IR_campo_rd
    lw		$t0, 0($t0)		    # $t0 <- Valor de IR_campo_rd - indice do registrador rd
    move 	$a0, $t0		    # $a0 = Valor de IR_campo_rd
    move 	$a1, $t2		    # $a0 = Valor a ser armazenado em rd
    jal     escreve_registrador

    lw		$ra, 0($sp)
    lw		$s0, 4($sp)
    lw		$s1, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM execute_mul #####
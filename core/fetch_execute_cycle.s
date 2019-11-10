.text
.eqv    mask_op_code    0xFC000000 # -> 31 - 26 (6)      OP
.eqv    mask_rs         0x03E00000 # -> 25 - 21 (5)     RS
.eqv    mask_rt         0x001F0000 # -> 20 - 16 (5)     RT
.eqv    mask_rd         0x0000F800 # -> 15 - 11 (5)     RD
.eqv    mask_shamt      0x000007C0 # -> 10 - 6  (5)     SHAMT
.eqv    mask_funct      0x0000003F # -> 5  - 0  (6)     FUNCT
.eqv    mask_imm_i      0x0000FFFF # -> 15 - 0  (16)    IMM (Tipo I)
.eqv    mask_imm_j      0x03FFFFFF # -> 25 - 0  (26)    IMM (Tipo J)

##############
# Argumentos:
# Nenhum
# Este procedimento executa o fetch-decode-execute cycle em um round
fetch_execute_cycle:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)
    
    jal		fetch_instruction   # jump to fetch_instruction and save position to $ra
    # Agora a instrucao a ser decodificada se encontra em IR
    

    lw		$ra, 0($sp)
    addiu   $sp, $sp, 4
    jr		$ra					# jump to $ra
##### FIM fetch_execute_cycle #####
    

##############
# Argumentos:
# Nenhum
# Este procedimento faz o fetch da instrucao, coloca em IR e incrementa o PC. 
fetch_instruction:
    addiu   $sp, $sp, -16
    sw		$s0, 0($sp) # Endereco a buscarmos na memoria de dados
    sw		$s1, 4($sp) # Instrucao sendo montada
    sw		$s2, 8($sp) # Contador
    sw		$ra, 12($sp) 
    
    li		$s1, 0x00000000		# $s1 = 0x00000000
    li		$s2, 0		        # $s2 = 0
    
    la		$t0, PC		# $t0 <- Endereco de PC
    lw		$s0, 0($t0) # $t1 <- Endereco armazenado em PC

    inicio_laco_fetch:
        li		$t0, 4		# $t0 = 4
        bge		$s2, $t0, fim_laco_fetch	# if $s2(contador) >= 4 then fim_laco_fetch
        
        sll     $s1, $s1, 8     # Desloca dois bits para a esquerda para encaixar o proximo byte
        move 	$a0, $s0		# $a0 = Endereco da instrucao
        jal     leia_memoria
        or      $s1, $s1, $v0   # Encaixamos o byte mais a direita da palavra sendo montada
        addi	$s0, $s0, 4		# $s0 = Endereco armazenado em PC + 4
        addi	$s2, $s2, 1     # contador++
        
        j       inicio_laco_fetch
    fim_laco_fetch:
    
    la		$t0, IR		# $t0 <- Endereco de IR
    sw		$s1, 0($t0) # IR <- Instrucao montada

    la		$t0, PC		# $t0 <- Endereco de PC
    sw		$s0, 0($t0) # PC <- Endereco para a proxima instrucao

    lw		$s0, 0($sp)
    lw		$s1, 4($sp)
    lw		$s2, 8($sp)
    lw		$ra, 12($sp) 
    addiu   $sp, $sp, 16
    jr		$ra					# jump to $ra
##### FIM fetch_instruction #####


##############
# Argumentos:
# Nenhum
# Este procedimento faz o decode da instrucao que
# esta em IR e coloca em cada um dos seus respectivos IR_campo 
decode_instruction:
    addiu   $sp, $sp, -8
    sw		$s0, 0($sp)
    sw		$ra, 4($sp) 
    
    la		$t0, IR		# $t0 <- Endereco de IR
    lw		$s0, 0($t0) # $s0 <- Valor guardado em IR (Instrucao a ser decodificada)

    ### DECODE OP
    andi    $t0, $s0, mask_op_code  # Aplica mask_op_code
    srl     $t0, $t0, 26            # Desloca 26 bits pra direita
    la		$t1, IR_campo_op		# $t1 <- Endereco do IR_campo_op
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_op

    ### DECODE RS
    andi    $t0, $s0, mask_rs       # Aplica mask_rs
    srl     $t0, $t0, 21            # Desloca 21 bits pra direita
    la		$t1, IR_campo_rs		# $t1 <- Endereco do IR_campo_rs
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_rs

    ### DECODE RT
    andi    $t0, $s0, mask_rt       # Aplica mask_rt
    srl     $t0, $t0, 16            # Desloca 16 bits pra direita
    la		$t1, IR_campo_rt		# $t1 <- Endereco do IR_campo_rt
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_rt

    ### DECODE RD
    andi    $t0, $s0, mask_rd       # Aplica mask_rd
    srl     $t0, $t0, 11            # Desloca 11 bits pra direita
    la		$t1, IR_campo_rd		# $t1 <- Endereco do IR_campo_rt
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_rd

    ### DECODE SHAMT
    andi    $t0, $s0, mask_shamt    # Aplica mask_rd
    srl     $t0, $t0, 6             # Desloca 6 bits pra direita
    la		$t1, IR_campo_shamt		# $t1 <- Endereco do IR_campo_shamt
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_shamt

    ### DECODE FUNCT
    andi    $t0, $s0, mask_funct    # Aplica mask_funct (Nao necessario deslocar para a direita)
    la		$t1, IR_campo_funct		# $t1 <- Endereco do IR_campo_funct
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_funct

    ### DECODE IMM - Tipo I
    andi    $t0, $s0, mask_imm_i    # Aplica mask_funct (Nao necessario deslocar para a direita)
    la		$t1, IR_campo_imm		# $t1 <- Endereco do IR_campo_imm
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_imm

    ### DECODE IMM - Tipo J
    andi    $t0, $s0, mask_imm_j    # Aplica mask_funct (Nao necessario deslocar para a direita)
    la		$t1, IR_campo_j		    # $t1 <- Endereco do IR_campo_j
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_j

    lw		$s0, 0($sp) 
    lw		$ra, 4($sp) 
    addiu   $sp, $sp, 8
    jr		$ra					# jump to $ra
##### FIM decode_instruction #####
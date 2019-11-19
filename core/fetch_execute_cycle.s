.data:
.align 2
error_finding_op: .asciiz "Erro: OP CODE nao mapeado\n"
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
    jal		decode_instruction  # jump to decode_instruction and save position to $ra
    jal		execute_instruction # jump to execute_instruction and save position to $ra

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
        
        srl     $s1, $s1, shift_1_byte      # Desloca dois bits para a esquerda para encaixar o proximo byte
        move 	$a0, $s0		# $a0 = Endereco da instrucao
        jal     leia_memoria
        sll     $v0, $v0, shift_3_byte
        or      $s1, $s1, $v0   # Encaixamos o byte mais a esquerda da palavra sendo montada
        addi	$s0, $s0, 1		# $s0 = Endereco armazenado em PC + 1
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
    move 	$a0, $t0		        # $a0 = $t0 (Valor a ser extendido)
    li      $a1, 15                 # $a1 = 15 (Index do bit a ser usado na extensao de sinal)
    jal     extend_signal
    move 	$t0, $v0		        # $t0 = $v0 (Valor extendido)
    la		$t1, IR_campo_imm		# $t1 <- Endereco do IR_campo_imm
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_imm

    ### DECODE IMM - Tipo J
    andi    $t0, $s0, mask_imm_j    # Aplica mask_funct (Nao necessario deslocar para a direita)
    move 	$a0, $t0		        # $a0 = $t0 (Valor a ser extendido)
    li      $a1, 25                 # $a1 = 25 (Index do bit a ser usado na extensao de sinal)
    jal     extend_signal
    move 	$t0, $v0		        # $t0 = $v0 (Valor extendido)
    la		$t1, IR_campo_j		    # $t1 <- Endereco do IR_campo_j
    sw		$t0, 0($t1)		        # $t0 -> IR_campo_j

    lw		$s0, 0($sp) 
    lw		$ra, 4($sp) 
    addiu   $sp, $sp, 8
    jr		$ra					# jump to $ra
##### FIM decode_instruction #####

##############
# Argumentos:
# Nenhum
# Este procedimento identifica qual eh o tipo de operacao deve ser executada
# a partir do opcode
execute_instruction:
    addiu   $sp, $sp, -4
    sw		$ra, 0($sp)

    la      $t0, IR_campo_op
    lw		$t0, 0($t0)		    # $t0 <- OP CODE

    # Etapa de identificacao - Primeira
    li      $t1, 0x09
    beq		$t0, $t1, operation_eh_addiu	    # if OP CODE == 0x09 then operation_code_eh_0x09

    li      $t1, 0x00
    beq		$t0, $t1, operation_code_eh_0x00	# if OP CODE == 0x00 then operation_code_eh_0x00
    
    li      $t1, 0x2b
    beq		$t0, $t1, operation_code_eh_sw	    # if OP CODE == 0x2b then operation_code_eh_sw

    li      $t1, 0x08
    beq		$t0, $t1, operation_code_eh_addi	# if OP CODE == 0x08 then operation_code_eh_addi

    li      $t1, 0x03
    beq		$t0, $t1, operation_code_eh_jal	    # if OP CODE == 0x02 then operation_code_eh_jal

    li      $t1, 0x23
    beq		$t0, $t1, operation_code_eh_lw	    # if OP CODE == 0x23 then operation_code_eh_lw
    
    li      $t1, 0x0f
    beq		$t0, $t1, operation_code_eh_lui	    # if OP CODE == 0x0f then operation_code_eh_lui

    li      $t1, 0x05
    beq		$t0, $t1, operation_code_eh_bne	    # if OP CODE == 0x05 then operation_code_eh_bne

    li      $t1, 0x0d
    beq		$t0, $t1, operation_code_eh_ori	    # if OP CODE == 0x0d then operation_code_eh_ori

    li      $t1, 0x02
    beq		$t0, $t1, operation_code_eh_j	    # if OP CODE == 0x0d then operation_code_eh_j
    
    li      $t1, 0x1c
    beq		$t0, $t1, operation_code_eh_0x1c    # if OP CODE == 0x1c then operation_code_eh_0x1c

    j       erro_encontrar_op
    
    # Etapa de identificacao - Segunda
    operation_code_eh_0x00:
        # Agora identificamos a partido do FUNCT
        la      $t0, IR_campo_funct
        lw		$t0, 0($t0)		    # $t0 <- FUNCT

        li		$t1, 0x20		    # $t1 = 0x20
        beq		$t0, $t1, operation_eh_add	# if $FUNCT == 0x20 then operation_eh_add

        li		$t1, 0x21		    # $t1 = 0x21
        beq		$t0, $t1, operation_eh_addu	# if $FUNCT == 0x21 then operation_eh_addu

        li		$t1, 0x0c		    # $t1 = 0x0c
        beq		$t0, $t1, operation_eh_syscall	# if $FUNCT == 0x0c then operation_eh_syscall

        li		$t1, 0x08		    # $t1 = 0x08
        beq		$t0, $t1, operation_code_eh_jr	# if $FUNCT == 0x08 then operation_code_eh_jr
        

        j		erro_encontrar_op	# jump to fim_execute_instruction - Se chegar aqui entao o funct nao foi mapeado
    #####
    operation_code_eh_0x1c:
        # Agora identificamos a partido do FUNCT
        la      $t0, IR_campo_funct
        lw		$t0, 0($t0)		        # $t0 <- FUNCT

        li		$t1, 0x02		    # $t1 = 0x02
        beq		$t0, $t1, operation_code_eh_mul	# if $FUNCT == 0x02 then operation_code_eh_mul

        j		erro_encontrar_op	# jump to fim_execute_instruction - Se chegar aqui entao o funct nao foi mapeado

    erro_encontrar_op:
    # Imprimir na tela mensagem de erro
    la		$t0, error_finding_op 
    move    $a0, $t0        # $a0 = $t0 (Endereço da mensgem de erro)
    jal     imprime_string  # imprime string
    
    la      $t0, IR
    la		$a0, buffer_general
    lw		$a1, 0($t0)		        # $a1 <- OP CODE
    jal		convert_hex_2_string    # Converte Hex to String
    la		$a0, buffer_general
    jal     imprime_string  # imprime string

    j       fim_execute_instruction


    # Etapa de execucao
    operation_eh_addiu:
        jal execute_addiu
    j   fim_execute_instruction
    ###
    operation_eh_add:
        jal execute_add
    j   fim_execute_instruction
    ###
    operation_eh_addu:
        jal execute_addu
    j   fim_execute_instruction
    ###
    operation_eh_syscall:
        jal execute_syscall
    j   fim_execute_instruction
    ###
    operation_code_eh_sw:
        jal execute_sw
    j   fim_execute_instruction
    ###
    operation_code_eh_addi:
        jal executa_addi
    j   fim_execute_instruction
    ###
    operation_code_eh_jal:
        jal execute_jal
    j   fim_execute_instruction
    ###
    operation_code_eh_lw:
        jal execute_lw
    j   fim_execute_instruction
    ###
    operation_code_eh_lui:
        jal execute_lui
    j   fim_execute_instruction
    ###
    operation_code_eh_bne:
        jal execute_bne
    j   fim_execute_instruction
    ###
    operation_code_eh_ori:
        jal execute_ori
    j   fim_execute_instruction
    ###
    operation_code_eh_jr:
        jal execute_jr
    j   fim_execute_instruction
    ###
    operation_code_eh_j:
        jal execute_j
    j   fim_execute_instruction
    ###
    operation_code_eh_mul:
        jal execute_mul
    j   fim_execute_instruction

    fim_execute_instruction:

    la      $t0, IR
    la		$a0, buffer_general
    lw		$a1, 0($t0)		        # $a1 <- OP CODE
    jal		convert_hex_2_string    # Converte Hex to String
    la		$a0, buffer_general
    jal     imprime_string  # imprime string

    lw		$ra, 0($sp) 
    addiu   $sp, $sp, 4
    jr		$ra					# jump to $ra
##### FIM execute_instruction #####

.include "instructions.s"
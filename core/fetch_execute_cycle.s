.text

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


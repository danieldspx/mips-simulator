.data

#################################################################################
# variáveis para o simulador
#################################################################################

# registradores de uso geral 

buffer_linha: .space 256       # linhas com até 256 caracteres
error_command_not_found: .asciiz "Comando nao encontrado\n"


.text
.include "global_variables.s"
main:
    #INITIALIZE SOME GLOBAL VARIABLES
    jal		initialize_variables				# jump to initialize_variables and save position to $ra
    

    laco_infinito_main:
        la      $a0, buffer_linha
        jal     leia_linha    
        la      $a0, buffer_linha
        jal     identifica_comando_e_chama_procedimento
    j laco_infinito_main

    li  $v0, 17
    syscall
######### FIM DA MAIN #########


##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
identifica_comando_e_chama_procedimento:
    addiu   $sp, $sp, -12
    sw		$s0, 0($sp) 
    sw		$s1, 4($sp) 
    sw		$ra, 8($sp)

    la      $s0, 0($a0) # $s0 <- Endereco inicial do vetorDeCaracteres
    move 	$s1, $s0    # $s1 = $s0  -  $s1 vai ser o cursor que percorre o vetor de caracteres

    # $t0 vai ser o caractere a ser testado
    # $t1 = vetorDeCaracteres[0]
    lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[0]
    li		$t0, 'r'		# $t0 = 'r'
    beq		$t0, $t1, comando_eh_r	# if $t0 == $t1 then comando_eh_r

    li		$t0, 'd'		# $t0 = 'd'
    beq		$t0, $t1, comando_eh_d	# if $t0 == $t1 then comando_eh_d

    li		$t0, 'm'		# $t0 = 'm'
    beq		$t0, $t1, comando_eh_m	# if $t0 == $t1 then comando_eh_m

    li		$t0, 'l'		# $t0 = 'l'
    beq		$t0, $t1, caractere_eh_l	# if $t0 == $t1 then caractere_eh_l

    j		comando_nao_encontrado

    caractere_eh_l:
        addi	$s1, $s1, 1		# $s1 =$s1 + 1
        lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[1]

        li		$t0, 't'		# $t0 = 't'
        beq		$t0, $t1, comando_eh_lt	# if $t0 == $t1 then comando_eh_lt

        li		$t0, 'd'		# $t0 = 'd'
        beq		$t0, $t1, comando_eh_ld	# if $t0 == $t1 then comando_eh_ld

        j		comando_nao_encontrado

    comando_eh_lt:
        addi	$s1, $s1, 1		# $s1 = &vetorDeCaracteres[1] + 1
        lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[2]
        li      $t0, ' '
        bne		$t1, $t0, comando_nao_encontrado	# if vetorDeCaracteres[1] != ' ' then comando_nao_encontrado

        move    $a0, $s0        # $a0 = $s0
        jal     executa_comando_lt
        j		fim_identifica
    comando_eh_ld:
        addi	$s1, $s1, 1		# $s1 = &vetorDeCaracteres[1] + 1
        lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[2]
        li      $t0, ' '
        bne		$t1, $t0, comando_nao_encontrado	# if vetorDeCaracteres[2] != ' ' then comando_nao_encontrado

        move    $a0, $s0        # $a0 = $s0
        jal     executa_comando_ld
        j		fim_identifica
    comando_eh_r:
        addi	$s1, $s1, 1		# $s1 = &vetorDeCaracteres[0] + 1
        lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[1]
        li      $t0, ' '
        bne		$t1, $t0, comando_nao_encontrado	# if vetorDeCaracteres[1] != ' ' then comando_nao_encontrado
        
        move    $a0, $s0        # $a0 = $s0 (&vetorDeCaracteres[0])
        jal     executa_comando_r
        j		fim_identifica
    comando_eh_d:
        addi	$s1, $s1, 1		# $s1 = &vetorDeCaracteres[0] + 1
        lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[1]
        li      $t0, '\0'
        bne		$t1, $t0, comando_nao_encontrado	# if vetorDeCaracteres[1] != '\0' then comando_nao_encontrado
        jal		executa_comando_d				# jump to executa_comando_d and save position to $ra
        j		fim_identifica
    comando_eh_m:
        addi	$s1, $s1, 1		# $s1 = &vetorDeCaracteres[0] + 1
        lb		$t1, 0($s1)		# $t1 = vetorDeCaracteres[1]
        li      $t0, ' '
        bne		$t1, $t0, comando_nao_encontrado	# if vetorDeCaracteres[1] != ' ' then comando_nao_encontrado
        
        jal		executa_comando_m

        j		fim_identifica

    comando_nao_encontrado:
        la		$t0, error_command_not_found 
        move    $a0, $t0        # $a0 = $t0
        jal     imprime_string
        j       fim_identifica

    fim_identifica:
    lw		$s0, 0($sp) 
    lw		$s1, 4($sp) 
    lw		$ra, 8($sp)
    addiu   $sp, $sp, 12
    jr      $ra
##### FIM identifica_comando_e_chama_procedimento #####


##############
# Argumentos:
# Nao ha argumentos
initialize_variables:
    addiu   $sp, $sp, -4
    sw      $ra, 0($sp)

    la		$t0, PC		    # Carrega endereco de PC em $t0
    li      $t1, PC_DEFAULT # $t1 = PC_DEFAULT (0x00400000)
    sw      $t1, 0($t0)     # PC_DEFAULT -> PC

    li		$a0, 29		    # $a0 = Indice do $sp = $29
    la      $a1, SP_DEFAULT # $a1 = SP_DEFAULT (0x7FFFEFFC)
    jal		escreve_registrador # jump to escreve_registrador and save position to $ra
    
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 4
    jr      $ra
##### FIM initialize_variables #####

.include "keyboard_display.s"
.include "utils_baratto.s"
.include "utils.s"
.include "comands/executa_lt.s"
.include "comands/executa_ld.s"
.include "comands/executa_d.s"
.include "comands/executa_m.s"
.include "comands/executa_r.s"
.include "core/fetch_execute_cycle.s"
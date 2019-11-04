#*******************************************************************************
# keyboard_display.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: procedimentos relacionados à ferramenta keyboard and display MMIO do MARS
#
# Para o keyboard, usamos os seguintes registradores
# RCR - receiver control register    | 0xFFFF0000
# RDR - receiver data register       | 0xFFFF0004
#
# Para o display temos os seguintes registradores
# TCR - transmitter control register | 0xFFFF0008
# TDR - transmitter data register    | 0xFFFF000C
#
# Para ler um caracter do keyboard
# 1. leia o conteúdo do endereço 0xFFFF0000 (receiver control register)
# 2. Verifique o bit menos significativo do receiver control register
# 3. Se 0 vá para o item 1 senão leia o caracter digitado do endreço
#    0xFFFF0004 (receiver data register)
#
# Para escrever um caracter em display
# 1. leia o conteúdo do endereço 0xFFFF0008 (transmitter control register)
# 2. Verifique o bit menos significativo do dado lido
# 3. Se 0 vá para o item 1 (continue esperando até que o bit menos
#    significativo do transmitter control register seja igual a 1).
#    Se 1 escreva no display. Isto é feito escrevendo um dado no
#    endereço 0xFFFF000C (transmitter data register).
#
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    08.10.2019     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O               #

.text


################################################################################            
leia_caractere:
# Este procedimento lê um caractere da ferramenta keyboard
#
# Argumentos do procedimento:
# sem argumentos 
#
# Mapa da pilha
# não usamos a pilha neste procedimento
#
# Mapa dos registradores
# $t0: endereço do RCR ou TCR
# $t1: RCR
#
# Retorno do procedimento
# $v0: caractere lido do terminal
################################################################################
# prólogo do procedimento
#corpo do procedimento
            # esperamos um caracter no terminal
            la    $t0, 0xFFFF0000   # endereço do RCR
laco_leia_caractere:
            lw    $t1, 0($t0)       # $t1 <- conteúdo do RCR
            andi  $t1, $t1, 0x0001  # isolamos o bit menos significativo
            beqz  $t1, laco_leia_caractere
            
            # lemos o carcater
            la    $t0, 0xFFFF0004   # endereço do RDR
            lw    $v0, 0($t0)       # $v0 <- caracter do terminal
# epílogo do procedimento
            jr    $ra
#-------------------------------------------------------------------------------            
            
################################################################################            
escreve_caractere:
# Este procedimento escreve um caractere na ferramenta display
#
# Argumentos do procedimento:
# $a0: caractere a ser apresentado no display.
#
# Mapa da pilha
# não usamos a pilha neste procedimento
#
# Mapa dos registradores
# $t0: endereço do TDR ou TCR
# $t1: TCR
#
# Retorno do procedimento
# Este procedimento não retorna nenhum dado
################################################################################
# prólogo do procedimento

# corpo do procedimento 
           # esperamos o display estar livre
            la    $t0, 0xFFFF0008   # endereço do TCR
laco_escreve_caractere:
            lw    $t1, 0($t0)       # $t1 <- conteúdo do TCR
            andi  $t1, $t1, 0x0001  # isolamos o bit menos significativo
            beqz  $t1, laco_escreve_caractere
            
            # escrevemos o carcatere no display
            la    $t0, 0xFFFF000C   # endereço do TDR
            sw    $a0, 0($t0)
# epílogo do procedimento
            jr    $ra

#-------------------------------------------------------------------------------

################################################################################            
leia_linha:
# Este procedimento faz a leitura de uma linha da ferramenta keyboard and display MMIO Simulator
# Argumentos do procedimento:
# $a0: endereço da string (buffer) que guarda os caracteres lidos de uma linha, da ferramenta display
#
# Mapa da pilha
# $sp + 8: endereço de retorno $ra
# $sp + 4: registrador $s1 - 
# $sp + 0: registrador $s0 - 
#
# Mapa dos registradores
# $s1: ponteiro para o caracter atual da string buffer
# $s0: endereço base (inicial) da string buffer
#
# Retorno do procedimento
# $v0: número de caracteres lido
################################################################################
# prólogo do procedimento
            addiu $sp, $sp, -12     # reservamos um espaço para 3 objetos na pilha
            sw    $ra, 8($sp)       # guardamos na pilha os registradores que devem ser salvos
            sw    $s1, 4($sp)       #
            sw    $s0, 0($sp)       #
# corpo do procedimento 
            # carregamos em $s0 o endereço da string que serve como buffer
            move  $s0, $a0
            # carregamos em $s1 o endereço inicial do ponteiro para o buffer
            move  $s1, $a0
            # fazemos a leitura de um caractere
leia_caractere_para_buffer:
            jal   leia_caractere
            # verificamos se é um fim de linha
            li    $t0, '\n'             # $t0 <- constante fim de linha: 0x0A
            bne   $v0, $t0, caractere_nao_eh_fim_linha
            # caractere é fim de linha. Marcamos o final da linha com o valor 0 e 
            # retornamos
            sb    $zero, 0($s1)         # armazenamos o valor zero na string
            j     epilogo_leia_linha    # vamos para o epílogo do procedimento
caractere_nao_eh_fim_linha:    
            # verificamos se o caracter é BS (backspace) = 0x08
            li    $t0, '\b'             # $t0 <- constante BS: 0x08
            bne   $v0, $t0, caractere_nao_eh_BS  
            # se caracter é backspace, apagamos, se possível, um caractere
            beq   $s0, $s1, leia_caractere_para_buffer # se apontamos para o início do buffer não há caracteres
            # apagamos um carater do buffer
            addiu $s1, $s1, -1          # apontamos para o caractere anterior
            j     leia_caractere_para_buffer # fazemos a leitura do próximo caractere
caractere_nao_eh_BS:
            # temos um caractere que deve ser colocado no buffer
            sb    $v0, 0($s1)           # guardamos o caractere no buffer
            addiu $s1, $s1, 1           # apontamos para a próxima posição do buffer
            j     leia_caractere_para_buffer # fazemos a leitura do próximo caractere         
# epílogo do procedimento
epilogo_leia_linha:
            lw    $ra, 8($sp)           # restauramos o endereço de retorno
            lw    $s1, 4($sp)           # restauramos $s1
            lw    $s0, 0($sp)           # restauramos $s0
            addiu $sp, $sp, 12          # restauramos a pilha
            jr    $ra                   # retornamos ao procedimento chamador
#-------------------------------------------------------------------------------
        

################################################################################            
imprime_string:
# Este procedimento imprime na ferramenta display uma string. Para marcar o final
# da string, usamos o caracatere nul=0x00.
#
# Argumentos do procedimento:
# $a0: endereço da string (buffer) que guarda os caracteres que serão apresentados no display
#
# Mapa da pilha
# $sp + 8: endereço de retorno $ra 
# $sp + 4: registrador $s1 -
# $sp + 0: registrador $s0 - 
#
# Mapa dos registradores
# $s1: caractere lido do buffer
# $s0: ponteiro para o caracter atual da string buffer
#
# Retorno do procedimento
# $v0: número de caracteres lido
################################################################################
# prólogo do procedimento
            addiu $sp, $sp,-8          # ajustamos a pilha para receber 2 itens
            sw    $ra, 4($sp)           # armazenamos os registradores que devem ser salvos
            sw    $s0, 0($sp)           #
# corpo do procedimento
            move  $s0, $a0              # inicializamos o apontador com o endereço inicial do buffer
laco_proximo_caractere:   
            # lemos o caractere do buffer
            lbu   $a0, 0($s0)           # $a0 <- caractere do buffer
            # verificamos se existe pelo menos um caracter para ser impresso, senão, termina o procedimento
            beqz  $a0, epilogo_imprime_linha # se não existem caracteres termine o procedimento      
            # imprime o caractere
            jal   escreve_caractere     # escreve o caractere do buffer
            addiu $s0, $s0, 1           # apontamos para o próximo caractere do buffer
            j     laco_proximo_caractere # imprimimos o próximo carcatere
# epílogo do procedimento
epilogo_imprime_linha:
            lw    $s0, 0($sp)           # restauramos os registradores salvos com os valores originais
            lw    $ra, 4($sp)           # 
            addiu $sp, $sp, 8           # restauramos a pilha
            jr    $ra                   # retornamos ao procedimento chamador
#-------------------------------------------------------------------------------



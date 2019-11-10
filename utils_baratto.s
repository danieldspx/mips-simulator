#*******************************************************************************
# dicas.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: 
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
# procedimento para ler um registrador. Lembre que os registradores no simulador
# são representados pelas variável registradores. 
#
# Argumentos
#   $a0: número i do registrador, para a leitura
#
# Retorno:
#   $v0: conteúdo do registrador
#
# Uso:
# ex.: leitura do registrador $t0 = $8
#           li      $a0, 0
#           jal     leia_registrador
#           -- o conteúdo do registrador está no registrador $v0
leia_registrador:
################################################################################
# prólogo do procedimento
# corpo do procedimento
# Se o registrador é o 0 ou $zero, seu valor será sempre 0
            bne     $a0, $zero, leia_registrador_nao_zero # se o registrado não é $zero, leia o registrador
            li      $v0, 0 # se for $zero, retorne 0
            j       epilogo_leia_registrador
leia_registrador_nao_zero:
            la      $t0, registradores # $t0 <- endereço base da variável registradores
            sll     $a0, $a0, 2        # $a0 <- 4 * i, i é número do registrador
            addu    $t0, $t0, $a0      # $t0 <- endereço efetivo do registrador i
            lw      $v0, 0($t0)        # $v0 <- valor do registrador i
epilogo_leia_registrador:            
# epílogo do procedimento
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------



################################################################################            
escreve_registrador:
# procedimento para escrever um registrador. Lembre que os registradores no simulador
# são representados pelas variável registradores. 
#
# Argumentos
#   $a0: número i do registrador, para a escrita
#   $a1: dado armazenado no registrador
#
# Uso:
# ex.: escrita do valor 0x55 no registrador $t0 = $8
#           li      $a0, 8
#           li      $a1, 0x55
#           jal     escreve_registrador
#           -- o registrador $t0 possui agora o valor 0x55
#           
################################################################################
# prólogo do procedimento
# corpo do procedimento
# se o registrador é o $zero, não podemos escrever
            bne     $a0, $zero, escreve_registrador_nao_zero
            j       epilogo_escreve_registrador
escreve_registrador_nao_zero:
            la      $t0, registradores # $t0 <- endereço base da variável registradores
            sll     $a0, $a0, 2        # $a0 <- 4 * i, i é número do registrador
            addu    $t0, $t0, $a0      # $t0 <- endereço efetivo do registrador i
            sw      $a1, 0($t0)        # escrevemos no registrador
epilogo_escreve_registrador:
# epílogo do procedimento
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------


################################################################################
# procedimento que verifica se um endereço pertence a um segmento de memória
#
# argumentos
# $a0: endereço
# $a1: endereço inicial do segmento de memória
# $a2: endereço final do segmento de memória
#
# valor de retorno
# $v0: 1 se pertence ao segmento, 0 se não pertende
pertence_segmento_memoria:
################################################################################
# prólogo do procedimento
# corpo do procedimento
# verificamos se $a0 >= $a1
            sgeu    $v0, $a0, $a1
            beq     $v0, $zero, epilogo_pertence_segmento # se 0, não pertence ao segmento
# verificamos se $a0 <= $a2
            sleu    $v0, $a0, $a2
epilogo_pertence_segmento:
# epílogo do procedimento
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------


################################################################################
escreve_memoria:
# 
# Este procedimento escreve um dado na memoria, se o endereço estiver em um
# dos 3 segmentos definidos no simulador. Se o endereço não estiver em um dos
# endereços, apresenta uma mensagem de erro no terminal do simulador.
#
# observação: A escrita de uma palavra (sw) de um endereço requer 4 chamadas a 
# este procedimento, usando endereço, endereço + 1, endereço + 2 e endereco + 3, 
# pois cada chamada escreve apenas um byte. Use o formato litte endian, escrevendo
# o byte menos significativo (mais a direita) para o byte mais significativo 
# (mais a esquerda) da palavra.
#
#
# Argumentos:
#   $a0: endereço de memória
#   $a1: dado para escrever na memória (1 byte)
# 
# Mapa da pilha:
#   $sp + 8: $ra - este procedimento chama outro procedimento.
#   $sp + 4: $s1 - usamos estes registradores e estes devem ser salvos
#   $sp + 0: $s0 -
#
# Uso:
# Ex.: desejamos escrever o byte 0x55 no endereço 0x10010000
#           li      $a0, 0x10010000
#           li      $a1, 0x55
#           jal     escreve_memoria
#           --      no endereço 0x1001000 (segmento de dados) está armazenado o 
#                   valor 0x55
#
################################################################################
# prólogo do procedimento
            addiu   $sp, $sp, -12    # vamos armazenar 3 itens na pilha
            sw      $ra, 8($sp)
            sw      $s1, 4($sp)
            sw      $s0, 0($sp)
# corpo do procedimento
            # armazenamos os arrgumentos nos registradores $s0 e $s1 porque chamaremos
            # um procedimento 
            move    $s0, $a0 # $s0 <- endereço de memória
            move    $s1, $a1 # $s1 <- dado para escrita no endereço de memoria
            # verificamos se o endereço pertence ao segmento de instruções
escreve_memoria_instrucoes:            
            #       $a0 já possui o endereço de memória
            li      $a1, ei_memoria_instrucoes
            li      $a2, ef_memoria_instrucoes
            jal     pertence_segmento_memoria # endereço pertence ao segmento de instruções?
            # se não pertence, verifica o segmento de dados
            beq     $v0, $zero, escreve_memoria_dados
            # se pertence, escreve na variável memoria_instrucoes
            # verificamos o índice: indice = endereco - endereco_inicial
            li      $t0, ei_memoria_instrucoes
            sub     $t1, $s0, $t0 # $t1 -> índice associado ao endereço de memória
            # calculamos o endereço efetivo do índice na memoria_instrucoes
            # como o vetor da memória de instruções é organizada em bytes, o endereço efetivo
            # será: EF(i) = EB + i* tam, tam = 1, EF(i) = EB + i
            la      $t0, memoria_instrucoes # $t0 -> endereço base da memoria de instruções
            addu    $t2, $t0, $t1 # $t2 -> endereço efetivo do elemento na memória de instruções
            sb      $s1, 0($t2) # escreve na variável memoria_instrucoes
            j       epilogo_escreve_memoria # termina o procedimento
escreve_memoria_dados:   
            move    $a0, $s0 # endereço de memória
            li      $a1, ei_memoria_dados
            li      $a2, ef_memoria_dados
            jal     pertence_segmento_memoria # endereço pertence ao segmento de dados?
            # se não pertence, verifica o segmento da pilha
            beq     $v0, $zero, escreve_memoria_pilha            
            # se pertence, escreve na variável memoria_dados
            # verificamos o índice: indice = endereco - endereco_inicial
            li      $t0, ei_memoria_dados
            sub     $t1, $s0, $t0 # $t1 -> índice associado ao endereço de memória
            # calculamos o endereço efetivo do índice na memoria_dados
            # como o vetor da memória de dados é organizada em bytes, o endereço efetivo
            # será: EF(i) = EB + i* tam, tam = 1, EF(i) = EB + i
            la      $t0, memoria_dados # $t0 -> endereço base da memoria de dados
            addu    $t2, $t0, $t1 # $t2 -> endereço efetivo do elemento na memória de dados
            sb      $s1, 0($t2) # escreve na variável memoria_dados
            j       epilogo_escreve_memoria # termina o procedimento            
escreve_memoria_pilha:    
            move    $a0, $s0
            li      $a1, ei_memoria_pilha
            li      $a2, ef_memoria_pilha
            jal     pertence_segmento_memoria # endereço pertence ao segmento da pilha?
            # se não pertence, temos um erro, o endereço não pertence a nenhum endereço
            beq     $v0, $zero, escreve_mensagem_erro           
            # se pertence, escreve na variável memoria_pilha
            # verificamos o índice: indice = endereco - endereco_inicial
            li      $t0, ei_memoria_pilha
            sub     $t1, $s0, $t0 # $t1 -> índice associado ao endereço da pilha
            # calculamos o endereço efetivo do índice na memoria_pilha
            # como o vetor da memória de dados é organizada em bytes, o endereço efetivo
            # será: EF(i) = EB + i* tam, tam = 1, EF(i) = EB + i
            la      $t0, memoria_pilha # $t0 -> endereço base da memoria da pilha
            addu    $t2, $t0, $t1 # $t2 -> endereço efetivo do elemento na memória da pilha
            sb      $s1, 0($t2) # escreve na variável memoria_pilha
            j       epilogo_escreve_memoria # termina o procedimento            
escreve_mensagem_erro:
            la      $a0, msg_erro_escreve_memoria
            li      $v0, 4
            syscall
epilogo_escreve_memoria:
# epílogo do procedimento
            # restauramos os valores originais dos registradores
            lw      $s0, 0($sp)
            lw      $s1, 4($sp)
            lw      $ra, 8($sp)
            # restauramos a pilha
            addiu   $sp, $sp, 12
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------
            
 
################################################################################ 
leia_memoria:
# Este procedimento lê um byte da memória, se o endereço estiver em um
# dos 3 segmentos definidos no simulador. Se o endereço não estiver em um dos
# endereços, apresenta uma mensagem de erro no terminal do simulador.
#
# observação: A leitura de uma palavra (lw) de um endereço requer 4 chamadas a 
# este procedimento, usando endereço, endereço + 1, endereço + 2 e endereco + 3, 
# pois cada chamada retorna apenas um byte. Use o formato litte endian, preenchendo
# a palavra do byte menos significativo (mais a direita) para o byte mais significativo
# (mais a esquerda) da palavra.
#             
#
# Argumentos:
#   $a0: endereço de memória
#
# valor de retorno:
#   $v0: dado (byte) associado ao endereço de memória
# 
# Mapa da pilha:
#   $sp + 8: $ra - este procedimento chama outro procedimento.
#   $sp + 4: $s1 - usamos estes registradores e estes devem ser salvos
#   $sp + 0: $s0 -
#
# Uso:
# Ex.: desejamos ler o endereço de memória 0x10010000
#           li      $a0, 0x10010000
#           jal     leia_memoria
#           -- o conteúdo (byte) do endereço 0x10010000 está no registrador $v0.
################################################################################
# prólogo do procedimento
            addiu   $sp, $sp, -12    # vamos armazenar 3 itens na pilha
            sw      $ra, 8($sp)
            sw      $s1, 4($sp)
            sw      $s0, 0($sp)
# corpo do procedimento
            # armazenamos os argumentos nos registradores $s0 e $s1 porque chamaremos
            # um procedimento 
            move    $s0, $a0 # $s0 <- endereço de memória
            move    $s1, $a1 # $s1 <- dado para escrita no endereço de memoria
            # verificamos se o endereço pertence ao segmento de instruções
le_memoria_instrucoes:            
            #       $a0 já possui o endereço de memória
            li      $a1, ei_memoria_instrucoes
            li      $a2, ef_memoria_instrucoes
            jal     pertence_segmento_memoria # endereço pertence ao segmento de instruções?
            # se não pertence, verifica o segmento de dados
            beq     $v0, $zero, le_memoria_dados
            # se pertence, escreve na variável memoria_instrucoes
            # verificamos o índice: indice = endereco - endereco_inicial
            li      $t0, ei_memoria_instrucoes
            sub     $t1, $s0, $t0 # $t1 -> índice associado ao endereço de memória
            # calculamos o endereço efetivo do índice na memoria_instrucoes
            # como o vetor da memória de instruções é organizada em bytes, o endereço efetivo
            # será: EF(i) = EB + i* tam, tam = 1, EF(i) = EB + i
            la      $t0, memoria_instrucoes # $t0 -> endereço base da memoria de instruções
            addu    $t2, $t0, $t1 # $t2 -> endereço efetivo do elemento na memória de instruções
            lbu     $v0, 0($t2) # lê na variável memoria_instrucoes
            j       epilogo_le_memoria # termina o procedimento
le_memoria_dados:    
            move    $a0, $s0
            li      $a1, ei_memoria_dados
            li      $a2, ef_memoria_dados
            jal     pertence_segmento_memoria # endereço pertence ao segmento de dados?
            # se não pertence, verifica o segmento da pilha
            beq     $v0, $zero, le_memoria_pilha            
            # se pertence, escreve na variável memoria_dados
            # verificamos o índice: indice = endereco - endereco_inicial
            li      $t0, ei_memoria_dados
            sub     $t1, $s0, $t0 # $t1 -> índice associado ao endereço de memória
            # calculamos o endereço efetivo do índice na memoria_dados
            # como o vetor da memória de dados é organizada em bytes, o endereço efetivo
            # será: EF(i) = EB + i* tam, tam = 1, EF(i) = EB + i
            la      $t0, memoria_dados # $t0 -> endereço base da memoria de dados
            addu    $t2, $t0, $t1 # $t2 -> endereço efetivo do elemento na memória de dados
            lbu     $v0, 0($t2) # lê na variável memoria_dados
            j       epilogo_le_memoria # termina o procedimento            
le_memoria_pilha:    
            move    $a0, $s0
            li      $a1, ei_memoria_pilha
            li      $a2, ef_memoria_pilha
            jal     pertence_segmento_memoria # endereço pertence ao segmento da pilha?
            # se não pertence, temos um erro, o endereço não pertence a nenhum endereço
            beq     $v0, $zero, le_memoria_mensagem_erro           
            # se pertence, escreve na variável memoria_instrucoes
            # verificamos o índice: indice = endereco - endereco_inicial
            li      $t0, ei_memoria_pilha
            sub     $t1, $s0, $t0 # $t1 -> índice associado ao endereço da pilha
            # calculamos o endereço efetivo do índice na memoria_pilha
            # como o vetor da memória de dados é organizada em bytes, o endereço efetivo
            # será: EF(i) = EB + i* tam, tam = 1, EF(i) = EB + i
            la      $t0, memoria_pilha # $t0 -> endereço base da memoria da pilha
            addu    $t2, $t0, $t1 # $t2 -> endereço efetivo do elemento na memória da pilha
            lbu     $v0, 0($t2) # lê na variável memoria_pilha
            j       epilogo_le_memoria # termina o procedimento            
le_memoria_mensagem_erro:
            la      $a0, msg_erro_le_memoria
            li      $v0, 4
            syscall
            li      $v0, 0 # retornamos o valor 0
epilogo_le_memoria:
# epílogo do procedimento
            # restauramos os valores originais dos registradores
            lw      $s0, 0($sp)
            lw      $s1, 4($sp)
            lw      $ra, 8($sp)
            # restauramos a pilha
            addiu   $sp, $sp, 12
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------

            
################################################################################            
converte_string_decimal:
# Converte uma string em um valor decimal sem sinal.
#
# Converte uma string, com o endereço em $a0, em um valor decimal sem sinal. 
# Strings com números negativos não são aceitos, retorna um 0 e erro de conversão.
# as strings podem ter valores de "0" a "4294967295" (2^32-1)
# 
# Argumentos:
#   $a0: endereço da string
#   $a1: endereco da variável inteira para indicar que a conversão foi realizada
#        corretamente.
#   
# Valores de retorno:
#   $v0: valor da string decimal, 0 se a string não pode ser convertida
#
# Uso
# Ex.: converter a string teste, definida como uma variável estática
#           teste: .space 100 # uma string com 100 caracteres (bytes)
#      Vamos supo que em um momento possui o valor teste="123"
#      para realizar a conversão utilize também uma variável para indicar o estado
#      da conversão, por exemplo, definimos a variável ok:
#      .data
#           ok: .space 4
#      Para realizar a conversão usamos o seguinte código
#           la      $a0, teste      # endereço da string
#           la      $a1, ok         # endereço da variável com o estado da conversão
#           jal converte_string_decimal
#           ---  no registrador $v0 temos o valor 123 e o valor da variável ok 
#                será 1, indicando que a conversão foi realizada sem problemas.
#                Se a conversão da string para um valor numérico não pode ser 
#                realizada, o valor desta variável será 0.
################################################################################
# prólogo do procedimento
# corpo do procedimento
            li      $t0, 10         # base decimal
            li      $v0, 0          # usamos para calcular o valor da número decimal 
            li      $t3, 0          # a conversão não foi realizada
converte_string_decimal_laco:
            # verificamos se existem dígitos (como caracteres) na string 
            lbu     $t1, 0($a0)     # carregamos um  caracter 
            beq     $t1, 0, converte_string_decimal_fim # se fim string, termina o procedimento.
            # se o caractere for diferende de '0' a '9', ocorre um erro
            bltu    $t1, '0', converte_string_decimal_erro
            bgtu    $t1, '9', converte_string_decimal_erro
            li      $t3, 1          # caractere está entre '0' e '9'
            mul     $t2, $v0, $t0   # multiplicamos pela base
            addiu   $t1, $t1, -48   # convertemos o caractere ascii para valor
            add     $v0, $t2, $t1   # adicionamos o valor do próximo dígito da string
            addiu   $a0, $a0, 1     # apontamos para o próximo caractere da string
            j       converte_string_decimal_laco
converte_string_decimal_erro:
            li      $v0, 0          # retornamos 0
            li      $t3, 0          # indicamos que houve erro na conversão
converte_string_decimal_fim:    
            sw      $t3, 0($a1)     # armazenamos o estado da conversão: 1 sucesso
# epílogo do procedimento
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------

            
################################################################################            
converte_string_hexadecimal_para_decimal:
#
# Converte uma string hexadecimal para um número inteiro sem sinal. A string tem 
# o formato "0xM..M": começam com "0x" e em seguida caracteres M = '0' a 'F'.
# A string deve estar entre "0x0" a "0xFFFFFFFF", ou seja, o maior valor que pode
# ser convertido tem o valor 2^32-1 = 4294967295 = 0xFFFFFFFF.
#
# Argumentos
#   $a0: o endereço da string hexadecimal que será convertida
#   $a1: o endereço da variável inteira que recebe o estado da conversão. O valor desta
#        variável é 0 se a conversão não pode ser realizada.
#
# Valor de retorno:
#   $v0: o valor da string hexadecimal. Se a conversão não pode ser realizada, $v0 
#        será igual a 0.
#
# Uso
# Ex.: converter a string teste, definida como uma variável estática
#           teste: .space 100 # uma string com 100 caracteres (bytes)
#      Vamos supo que em um momento possui o valor teste="0x123"
#      para realizar a conversão utilize também uma variável para indicar o estado
#      da conversão, por exemplo, definimos a variável ok:
#      .data
#           ok: .space 4
#      Para realizar a conversão usamos o seguinte código
#           la      $a0, teste      # endereço da string hexadecimal
#           la      $a1, ok         # endereço da variável com o estado da conversão
#           jal converte_string_decimal
#           ---  no registrador $v0 temos o valor 291 (valor decimal) e o valor da 
#                variável ok será 1, indicando que a conversão foi realizada sem problemas.
#                Se a conversão da string para um valor numérico não pode ser 
#                realizada, o valor desta variável será 0.
################################################################################
# prólogo do procedimento
# corpo do procedimento
            li      $t0, 16         # base hexadecimal
            li      $v0, 0          # usamos para calcular o valor da string hexadecimal 
            li      $t3, 0          # a conversão não foi realizada
            # verificamos se os dois caracteres iniciais são "0x"
            lbu     $t1, 0($a0)     # carregamos o primeiro caractere
            li      $t4, '0'        # o primeiro caracatere deve ser '0'
            bne     $t1, $t4, converte_string_hexadecimal_fim # se não for, termina o procedimento
            addiu   $a0, $a0, 1     # apontamos para o próximo carcatere
            lbu     $t1, 0($a0)     # carregamos o próximo caractere
            li      $t4, 'x'        # o proximo caractere deve ser 'x'
            bne     $t1, $t4, converte_string_hexadecimal_fim # se não for, termina o procedimento
            addiu   $a0, $a0, 1     # avançamos para o próximo carcatere
converte_string_hexadecimal_laco:
            # verificamos se existem dígitos (como caracteres) na string 
            lbu     $t1, 0($a0)     # carregamos um  caracter 
            beq     $t1, 0, converte_string_hexadecimal_fim # se fim string, termina o procedimento.
            # se o caractere for diferende de '0' a '9' ou 'a' a 'f' ou 'A' a 'F', ocorre um erro
testa_caractere_0_a_9:            
            sgeu    $t4, $t1, '0'   # verifica se o caractere $t1 está entre '0' e '9' 
            sleu    $t5, $t1, '9'   #
            and     $t6, $t4, $t5   # $t6 = 1 se '0' <= $t1 <= '9'
            beq     $t6, $zero, testa_caractere_a_a_f # $t6 = 0, testa se 'a' <= $t1 <= 'f'
            addiu   $t1, $t1, -48   # ajusta o valor do caractere para 0 a 9
            j       converte_string_hexadecimal_realiza_conversao # adiciona no processo de conversão
testa_caractere_a_a_f:            
            sgeu    $t4, $t1, 'a'   # verifica se o caractere está entre 'a' e 'f'
            sleu    $t5, $t1, 'f'   #
            and     $t6, $t4, $t5   # $t6 = 1 se 'a' <= $t1 <= 'f'
            beq     $t6, $zero, testa_caractere_A_a_F # se $t6 = 0, verifica se 'A' <= $t1 <= 'F'
            addiu   $t1, $t1, -87   # ajusta o caracatere para valores entre 10 e 15
            j       converte_string_hexadecimal_realiza_conversao
testa_caractere_A_a_F:            
            sgeu    $t4, $t1, 'A'   # verifica se o caractere está entre 'A' e 'F'
            sleu    $t5, $t1, 'F'   #
            and     $t6, $t4, $t5   # $t6 = 1 se 'A' <= $t1 <= 'F'
            beq     $t6, $zero, converte_string_hexadecimal_erro # $t6 = 0, o caracatere não está entre '0' a '9' ou 'a' a 'f' (ou 'A' a 'F')
            addiu   $t1, $t1, -55   # ajusta o caractere para valores entre 10 e 15
converte_string_hexadecimal_realiza_conversao:            
            li      $t3, 1          # caractere representa dígito hexadecimal
            mul     $t2, $v0, $t0   # multiplicamos pela base
            add     $v0, $t2, $t1   # adicionamos o valor do próximo dígito da string
            addiu   $a0, $a0, 1     # apontamos para o próximo caractere da string
            j       converte_string_hexadecimal_laco # repetimos para o próximo caractere da string
converte_string_hexadecimal_erro:
            li      $v0, 0          # retornamos 0
            li      $t3, 0          # indicamos que houve erro na conversão
converte_string_hexadecimal_fim:    
            sw      $t3, 0($a1)     # armazenamos o estado da conversão: 1 sucesso
# epílogo do procedimento
            jr      $ra             # retorna ao procedimento chamador
#-------------------------------------------------------------------------------


.data
#################################################################################
# mensagens
#################################################################################
msg_erro_escreve_memoria: .asciiz "Erro na escrita na memória\n"
msg_erro_le_memoria: .asciiz "Erro na leitura da memória\n"


.data
#################################################################################
# variáveis para o simulador
#################################################################################
.align 2
#
buffer_general: .space 500
# registradores de uso geral 
registradores:  .space 128          # 32 registradores de uso geral (registradores de 32 bits)
# outros registradores
PC:             .space 4            # contador de programa (contém o endereço da instrução atual)
IR:             .space 4            # registrador de instrução (contém a instrução que é decodificada e executada)
hi:             .space 4            # registrador hi, usado nas operações de multiplicação e divisão
lo:             .space 4            # registrador lo, usado nas operações de multiplicação e divisão

# campos do registrador IR, usados na decodificação e execução
IR_campo_op:    .space 4            # campo opcode ou op - código de operação
IR_campo_rs:    .space 4            # endereço (número) do registrador rs
IR_campo_rt:    .space 4            # endereço (número) do registrador rt
IR_campo_rd:    .space 4            # endereço (número) do registrador rd
IR_campo_shamt: .space 4            # campo usado nas operações de deslocamento
IR_campo_funct: .space 4            # usado para completar a decodificação da instrução
IR_campo_imm:   .space 4            # campo imediato, um valor de 16 bits
IR_campo_j:     .space 4            # usado nas operações j, possui 26 bits

# segmentos de memória para as instruções, dados e pilha

# segmento de memória      (endereço final - endereço inicial) + 1
# as memórias são organizadas em bytes.
memoria_instrucoes: .space 65536    # segmento de memória para instruções (.text)
memoria_dados:      .space 65536    # segmento de memória para os dados (.data)
memoria_pilha:      .space 65536    # segmento de memoria da pilha

end_of_line: .asciiz "\n"
label_arrow: .asciiz " -> "
line_separator: .asciiz "--------------------\n"

.text
# definicoes dos endereços e valores padrão do simulador
# endereço inicial e final dos segmentos de memória para instruções, dados e a pilha
.eqv ei_memoria_instrucoes 0x00400000   # endereço inicial da memória de instruções
.eqv ef_memoria_instrucoes 0x0040FFFF   # endereço final da memória de instruções
.eqv ei_memoria_dados      0x10010000   # endereço inicial da memória de dados
.eqv ef_memoria_dados      0x1001FFFF   # endereço final da memória de dados
.eqv ei_memoria_pilha      0x7FFF0000   # endereço inicial da memória da pilha
.eqv ef_memoria_pilha      0x7FFFFFFF   # endereço final da memória da pilha

# valores padrão (default) para alguns registradores
.eqv PC_DEFAULT            0x00400000   # valor padrão do PC (program counter, contador de programa)
.eqv SP_DEFAULT            0x7FFFEFFC   # valor padrão do SP (stack pointer, apontador para a pilha)
.eqv GP_DEFAULT            0x10008000   # valor padrão do GP (global pointer, apontador global)

#Uteis
.eqv    shift_1_byte    8
.eqv    shift_2_byte    16
.eqv    shift_3_byte    24
.eqv    shift_4_byte    32
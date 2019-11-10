.text:
##############
# Argumentos:
# $a0 = &vetorDeCaracteres[0]
executa_comando_r:
    addiu	$sp, $sp, -4
    sw		$ra, 0($sp)
    
    jal     fetch_execute_cycle

    lw		$ra, 0($sp)
    addiu	$sp, $sp, 4
    jr      $ra
##### FIM executa_comando_r #####
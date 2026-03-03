# Laboratorio: Estructura de Computadores
# Actividad: Optimización de Pipeline en Procesadores MIPS
# Archivo: programa_optimizado.asm
# Descripción: Versión optimizada mediante reordenación de instrucciones para eliminar stalls.

.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8
    vector_y: .space 32          # Espacio para 8 enteros (8 * 4 bytes)
    const_a:  .word 3
    const_b:  .word 5
    tamano:   .word 8

.text
.globl main

main:
    # --- Inicialización ---
    la $s0, vector_x      # Cargar dirección base del vector X en $s0
    la $s1, vector_y      # Cargar dirección base del vector Y en $s1
    lw $t0, const_a       # Cargar el valor de la constante A en $t0
    lw $t1, const_b       # Cargar el valor de la constante B en $t1
    lw $t2, tamano        # Cargar el límite del bucle (8) en $t2
    li $t3, 0             # Inicializar el contador del índice i = 0 en $t3

loop:
    # --- Condición de salida ---
    beq $t3, $t2, fin     # Si i ($t3) == tamaño ($t2), saltar a la etiqueta fin
    
    # --- Preparación de direcciones ---
    sll $t4, $t3, 2       # Calcular desplazamiento: t4 = i * 4 (ajuste de bytes)
    addu $t5, $s0, $t4    # Calcular dirección exacta de X[i]: t5 = base_X + despl
    
    # --- Carga y Optimización (Reordenamiento) ---
    lw $t6, 0($t5)        # Iniciar carga de X[i] desde memoria al registro $t6
    
    # ESTA INSTRUCCIÓN HA SIDO MOVIDA AQUÍ:
    addu $t9, $s1, $t4    # Calcular dirección de Y[i] mientras se completa el 'lw'
    # Al colocar esta instrucción aquí, llenamos el hueco del stall de Load-Use.

    # --- Operaciones aritméticas ---
    mul $t7, $t6, $t0     # Calcular t7 = X[i] * A (Dato $t6 ya está listo sin stall)
    addu $t8, $t7, $t1    # Calcular t8 = (X[i] * A) + B
    
    # --- Almacenamiento ---
    sw $t8, 0($t9)        # Guardar el resultado final en la dirección de Y[i]
    
    # --- Control de bucle ---
    addi $t3, $t3, 1      # Incrementar el índice: i = i + 1
    j loop                # Saltar de regreso al inicio del bucle

fin:
    # --- Finalización ---
    li $v0, 10            # Cargar código de servicio para terminar ejecución
    syscall               # Llamada al sistema para cerrar el programa
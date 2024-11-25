.data
slist: 	.word 0
cclist: .word 0
wclist: .word 0
schedv: .space 32
menu: 	.ascii "Colecciones de objetos categorizados\n"
	.ascii "====================================\n"
	.ascii "1-Nueva categoria\n"
	.ascii "2-Siguiente categoria\n"
	.ascii "3-Categoria anterior\n"
	.ascii "4-Listar categorias\n"
	.ascii "5-Borrar categoria actual\n"
	.ascii "6-Anexar objeto a la categoria actual\n"
	.ascii "7-Listar objetos de la categoria\n"
	.ascii "8-Borrar objeto de la categoria\n"
	.ascii "0-Salir\n"
	.asciiz "Ingrese la opcion deseada: "
error: 	.asciiz "Error: "
return: .asciiz "\n"
catName:.asciiz "\nIngrese el nombre de una categoria: "
selCat: .asciiz "\nSe ha seleccionado la categoria:"
idObj: 	.asciiz "\nIngrese el ID del objeto a eliminar: "
objName:.asciiz "\nIngrese el nombre de un objeto: "
success:.asciiz "La operación se realizo con exito\n\n"
greater_symbol: .asciiz ">"
invalid_option: .asciiz "\nOpción inválida. Inténtelo de nuevo.\n"
mensajeNoEncontrado: .asciiz "No encontrado. \n"

.text
main:
	la $t0, schedv
	la $t1, newcategory
	sw $t1, 0($t0)              

	la $t1, siguienteCategoria
	sw $t1, 4($t0)              

	la $t1, categoriaAnterior
	sw $t1, 8($t0)              

	la $t1, listarCategorias
	sw $t1, 12($t0)             

	la $t1, eliminarCategoria
	sw $t1, 16($t0)             

	la $t1, nuevoObjeto
	sw $t1, 20($t0)             

	la $t1, listarObjetos
	sw $t1, 24($t0)             

	la $t1, eliminarObjeto
	sw $t1, 28($t0)             

menuBucle:
    	la $a0, menu #Mostrar el menú
    	li $v0, 4
    	syscall
    	
    	li $v0, 5 #Para que el usuario ingrese la opcion
    	syscall
    	move $t2, $v0 #Guardar opción en $t2

    	beqz $t2, exit #Para que el rango de opciones sea entre 1 y 8
    	li $t3, 1
    	blt $t2, $t3, opcionInvalida
    	li $t3, 8
    	bgt $t2, $t3, opcionInvalida

    	subi $t2, $t2, 1 #Calcular la posición en schedv (opción - 1) * 4
    	sll $t2, $t2, 2
    	la $t0, schedv
    	add $t0, $t0, $t2  #$t0 ahora tiene la dirección de la función en schedv

    	lw $t1, 0($t0) #Llamo a la funcion a través de la dirección guardada en $t0
    	jalr $t1  #Saltar a la funcion correspondiente

    	j menuBucle #Vuelvo al menú

opcionInvalida: #Para imprimir mensaje de opción inválida
    	la $a0, invalid_option
    	li $v0, 4
    	syscall
    	j menuBucle  #Vuelvo al menú

newcategory:
	addiu $sp, $sp, -4 
	sw $ra, 4($sp)	   	
	la $a0, catName    # input category name, en el argumento $a0 para poder imprimirlo
	jal getblock
	move $a2, $v0 # $a2 = *char to category name
	la $a0, cclist # $a0 = list
	li $a1, 0 # $a1 = NULL
	jal addnode
	lw $t0, wclist
	bnez $t0, newcategory_end
	sw $v0, wclist # update working list if was NULL
newcategory_end:
	li $v0, 0 # return success
	lw $ra, 4($sp)
	addiu $sp, $sp, 4
	jr $ra
siguienteCategoria:
    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)

    	lw $t0, cclist #Guardo en $t0 el comienzo de la lista
    	beqz $t0, error_201 #Si es igual a 0, error 201

    	lw $t1, wclist #Guardo en $t1 la categoria actual
    	lw $t2, 12($t1) #Cargo en $t2 la siguiente categoria
    	beq $t1, $t2, error_202 #Si la siguiente es igual a la actual, es porque solo hay una

    	sw $t2, wclist
    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	li $v0, 0
    	j siguienteCategoriaFin
error_201:
    	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 201
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 201
    	j siguienteCategoriaFin
error_202:
    	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 202
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
siguienteCategoriaFin:
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
    
categoriaAnterior:
    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)
    	
    	lw $t0, cclist        #Cargar la lista de categorías
    	beqz $t0, error_201   # Si no hay categorías

    	lw $t1, wclist #Guardo en $t1 la categoria actual
    	lw $t2, 0($t1) #Guardo en $t2 la categoria anterior
    	beq $t1, $t2, error_202 #Si la anterior es igual a la actual, es  porque solo hay una
 
    	sw $t2, wclist

    	lw $a0, 8($t2)
    	li $v0, 4 
    	syscall              

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra            

listarCategorias:
    	lw $t0, cclist
    	beqz $t0, list_error_301
    	lw $t2, wclist
    	move $t1, $t0
       
listarBucle:
    	bne $t1, $t2, listarBucle2
imprimirSimbolo:
    	la $a0, greater_symbol
    	syscall
listarBucle2:
    	lw $a0, 8($t1)
    	li $v0, 4
    	syscall
    	lw $t1, 12($t1)
    	bne $t1, $t0, listarBucle

listarCategoriaFin:
    	jr $ra

list_error_301:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 301
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 301
    	j listarCategoriaFin
    
    
eliminarCategoria:
    	addiu $sp, $sp, -4 
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_401

    	lw $t1, 4($t0)  
    	beqz $t1, eliminarCategoriaSinObjetos

    	move $a0, $t1
    	jal eliminarTodosObjetos  #Funcion para eliminar todos los objetos de la categoria
	
eliminarCategoriaSinObjetos:
    	lw $a0, wclist
    	lw $a1, cclist
    	lw $t5, 12($a0)
    	beq $t5, $a0, eliminarUltimaCategoria
    	sw $t5, wclist
    	bne $a0, $a1,  eliminarNodoCategoria
    	sw $t5, cclist
    	j eliminarNodoCategoria
  
eliminarUltimaCategoria:
    	sw $zero, cclist
	sw $zero, wclist
    	
eliminarNodoCategoria:	
	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

error_401:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 401
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 401
    	jr $ra
    
nuevoObjeto:
    	addiu $sp, $sp, -4 
    	sw $ra, 4($sp)
    	lw $t0, cclist
    	beqz $t0, error_501
    	la $a0, objName #Obtener nombre del objeto
    	jal getblock
    	move $a2, $v0
    	lw $t0, wclist
    	addi $t0, $t0, 4
    	move $a0, $t0
    	lw $t5, ($a0)
    	bnez  $t5, otroObjeto
    	li   $a1, 1
    	jal addnode
    	j   nuevoObjetoFin
    
otroObjeto:
    	lw $t4, ($t5)
    	lw $t5, 4($t4)
    	addiu $a1, $t5, 1
    	jal addnode

nuevoObjetoFin:
    	li $v0, 0
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra
	
error_501:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 501
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 501
    	jr $ra
    
    
listarObjetos:
    	lw $t0, wclist
    	beqz $t0, error_601

    	lw $t1, 4($t0)
   	beqz $t1, error_602

    	move $t2, $t1
listarObjetosBucle:
    	lw $a0, 8($t2)
    	li $v0, 4
    	syscall
    	lw $t2, 12($t2)
    	bne $t2, $t1, listarObjetosBucle

    	li $v0, 0
    	jr $ra

error_601:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 601
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 601
    	jr $ra

eliminarTodosObjetos:
    	addiu $sp, $sp, -4           
    	sw $ra, 4($sp)               

    	lw $t0, wclist               #$t0 apunta a la categoría seleccionada

    	beqz $t1, error_602          #Si la categoria no tiene objetos, imrpime error 602

eliminarTodosObjetosBucle:
    	lw $t2, 12($t1)              #$t2 guarda el puntero al siguiente objeto
    	lw $t3, 0($t1)               #$t3 guarda el puntero al objeto anterior
    	lw $t4, 8($t1)               #$t4 apunta al puntero de nombre del objeto
    
    	sw $t3, 0($t2)		#Establecer el anterior puntero del objeto siguiente
    	sw $t2, 12($t3) 		#Establecer el siguiente puntero del objeto anterior
    	
    	li $t5, 0                    
    	sw $t5, 0($t1)               #Pongo un cero en el puntero del nodo anterior
    	sw $t5, 4($t1)               #Pongo un cero en el puntero del nodo siguiente¿
    	sw $t5, 8($t1)               #Pongo un cero en el puntero al nombre
    	move $a0, $t1 
    	jal sfree #Para iberar el bloque de memoria del objeto
    	beq $t2, $t1, eliminarObjetoFin  # Si hemos llegado al final de la lista (el siguiente es igual al primero), terminamos Si el siguiente objeto es el primero, salimos del bucle
    	move $t1, $t2 # Continuamos con el siguiente objeto
    	j eliminarTodosObjetosBucle

eliminarObjetoFin:		
    	lw $t0, wclist
    	sw $zero, 4($t0) #Si eliminamos todos los objetos, ponemos en 0 la lista de objetos de la categoría elegida
    	li $v0, 0 # Indicamos que la operación se completó con éxito

    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra 

error_602:  #Mensaje de error para cuando no hay objetos 
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 602
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
    	li $v0, 602
    	jr $ra


 
    
eliminarObjeto:
    	addiu $sp, $sp, -4
    	sw $ra, 4($sp)
    	lw $t0, wclist
    	beqz $t0, error_701
    	la $a0, idObj
    	li $v0, 4
    	syscall
    	li $v0, 5
    	syscall							
    	move $t1, $v0  #ID buscado
    	lw $t2, 4($t0) #Primer objeto
    	lw $t4, 0($t2) #Ultimo objeto
    	lw $t3, 4($t4) #ID ultimo objeto
    	li $t5, 0
    	move $a1, $t2
       
eliminarObjetoBucle:
    	lw $t3, 4($t2)
    	beq $t1, $t3, objetoEncontrado
    	lw $t2, 12($t2)
    	bgt $t5, $t3, objetoNoEncontrado
    	addiu $t5, $t5, 1
    	bne $t2, $zero, eliminarObjetoBucle

objetoNoEncontrado:
	la $a0, mensajeNoEncontrado
    	li $v0, 4
    	syscall
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
    	jr $ra

objetoEncontrado:
    	lw $t4, 4($t0)
    	beq $t2, $t4, actualizarListaObjetos
    	
objetoEncontrado2:   
    	move $a0, $t2
    	jal delnode
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 4
   	jr $ra
    
actualizarListaObjetos:
    	lw  $t5, 12($t2)     #Guardo en $t5 el siguiente objeto
    	addiu $t4, $t0, 4    #Cargo la direccion donde la categoria tiene el puntero de la lista de objetos
    	seq $t6, $t5, $t2    #si el siguiente objeto es el mismo que se va a eliminar es porque solo hay uno 
    	bnez $t6, actualizarListaObjetos2 
    	sw  $t5, 0($t4)	
    	j   objetoEncontrado2
    
actualizarListaObjetos2:
    	sw  $zero, 0($t4)	#Actualizo el puntero de lista objetos a NULL
    	j   objetoEncontrado2   
    
error_701:
	la $a0, error
    	li $v0, 4
    	syscall
    	li $a0, 701
    	li $v0, 1
    	syscall
    	la $a0, return
    	li $v0, 4
    	syscall
   	li $v0, 701
    	jr $ra
    
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	jal smalloc
	sw $a1, 4($v0) # set node content
	sw $a2, 8($v0)
	lw $a0, 4($sp)
	lw $t0, ($a0) # first node address
	beqz $t0, addnode_empty_list
addnode_to_end:
	lw $t1, ($t0) # last node address
	# update prev and next pointers of new node
	sw $t1, 0($v0)
	sw $t0, 12($v0)
	# updat	e prev and first node to new node
	sw $v0, 12($t1)
	sw $v0, 0($t0)
	j addnode_exit
addnode_empty_list:
	sw $v0, ($a0)
	sw $v0, 0($v0)
	sw $v0, 12($v0)
addnode_exit:
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra
# a0: node address to delete
# a1: list address where node is deleted
delnode:
	addi $sp, $sp, -8
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	lw $a0, 8($a0) # get block address
	jal sfree # free block
	lw $a0, 4($sp) # restore argument a0
	lw $t0, 12($a0) # get address to next node of a0
node:
	beq $a0, $t0, delnode_point_self
	lw $t1, 0($a0) # get address to prev node
	sw $t1, 0($t0) # el anterior pasa a la siguiente categoria
	sw $t0, 12($t1)
	lw $t1, 0($a1) # get address to first node
again:
	bne $a0, $t1, delnode_exit
	sw $t0, ($a1) # list point to next node
	j delnode_exit
delnode_point_self:
	sw $zero, ($a1) # only one node
	#sw $zero, cclist
	#sw $zero, wclist
delnode_exit:
	jal sfree
	lw $ra, 8($sp)
	addi $sp, $sp, 8
	jr $ra

# a0: msg to ask
# v0: block address allocated with string
getblock:
	addi $sp, $sp, -4
	sw $ra, 4($sp) #guarda en stack el ra de new category
	li $v0, 4
	syscall	
	jal smalloc
	move $a0, $v0 # guarda en a0 la direccion de heap + 16 bytes
	li $a1, 16
	li $v0, 8
	syscall
	move $v0, $a0
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	 
smalloc:
	lw $t0, slist
	beqz $t0, sbrk
	move $v0, $t0
	lw $t0, 12($t0)
	sw $t0, slist
	jr $ra
sbrk:
	li $a0, 16 # node size fixed 4 words
	li $v0, 9  # llamo al heap reservando 16 bytes / 4 words
	syscall # return node address in v0
	jr $ra
sfree:
	lw $t0, slist
	sw $t0, 12($a0)
	sw $a0, slist # $a0 node address in unused list
	jr $ra
	
exit:
	li $v0, 10
	syscall

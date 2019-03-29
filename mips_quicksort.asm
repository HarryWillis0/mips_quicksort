# $a0 contains the address of the first string
# $a1 contains the address of the second string
# $v0 will contain the result of the function.
#

FUNCTION_STRCMP:
	# Save $s0, s1, s2, s3
	addi $sp,$sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	

	add $t0, $zero, $zero		# i = 0
	
LOOP:
	add $t2, $t0, $a0		# t2->str1[i]
	add $t3, $t0, $a1		# t2->str2[i]
	lbu $t4, 0($t2)			# $t2 = str1[t1]
	lbu $t5, 0($t3)			# $t4 = str2[t4]
	
	bne $t4, $t5, NOT_EQUAL		# str1[i] != str2[2], go compare
		
	beq $t4, $zero, RETURN_0	# are we at end of strings
	add $t0, $t0, 1

	j LOOP
	
NOT_EQUAL:
	slt $t6, $t4, $t5 		# test chars agains each other
	beq $t6, $zero, RETURN_1	# s1[i] comes after s2[i]
	
	li $v0, -1			# s1[i] must come before s2[i] 
	# restore s0, s1, s2, s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra				

RETURN_1:
	li $v0, 1
	# restore s0, s1, s2, s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
	jr $ra

RETURN_0:
	li $v0, 0
	# restore s0, s1, s2, s3
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
   	jr $ra

# $a0 contains the address of the first string array
# $a1 contains the address of the second string array
# $a2 contains the maximum length of the arrays
# 
	
FUNCTION_SWAP:
	# Save registers
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	
	subi $sp, $sp, MAX_WORD_LEN	# extend stack max length of the arrays.
	
	add $t0, $zero, $zero
	la $t1, ($sp)
	
COPY_S1: # copy s1 to temporary storage on stack.
	add $t4, $t0, $a0		# t4->str1[i]
	add $t1, $t0, $t1
	lbu $t3, 0($t4)			# $t3 = str1[i]
	sb $t3, 0($t1)			# put str1[i] on stack
	 
	beq $t3, $zero, DONE_COPY_1
	
	addi $t0, $t0, 1		# i++
		
	j COPY_S1			# LOOP
	
DONE_COPY_1:

	add $t0, $zero, $zero
		
COPY_S2:
	add $t4, $t0, $a0		# t4-> str1[i]
	
	add $t2, $t0, $a1		# t2->str2[i]
	lbu $t3, 0($t2)			# t3 = str2[i]
	
	sb $t3, 0($t4)			# str1[t2] = str2[t4]
	
	beq $t3, $zero, DONE_COPY_2

	addi $t0, $t0, 1
		
	j COPY_S2			# LOOP
	
DONE_COPY_2:

	la $t1, ($sp)		#t1->sp
	add $t0, $zero, $zero

COPY_STACK_S1:
	add $t2, $t0, $a1		#t2->str2[i]
	add $t1, $t0, $t1
	lbu $t3, ($t1)			# t3 = sp
	sb $t3, ($t2)			# str2[i] = str1[i]
	
	beq $t3, $zero, DONE_COPY_3
	
	add $t0, $t0, 1

	j COPY_STACK_S1			# LOOP

DONE_COPY_3:
	addi $sp, $sp, MAX_WORD_LEN 		# free space on stack
	# restore s0, s1, s2, $s3
			
	lw $s0, 0($sp)			
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra
	
#
# $a0 contains starting address of the array of strings
# $a3 contains amount to increment pointer
# $v1 contains the address of the index = counter into array
#

MOVE_PTR:
	move $t0, $s0			# t0->A[0]
	move $t1, $a3			# t1 = counter
loop: 	
	beq $t1, $zero, DONE_MOVE
	subi $t1, $t1, 1
	addi $t0, $t0, MAX_WORD_LEN		# next string
	j loop
DONE_MOVE:
	move $v1, $t0
	jr $ra

#
# $a0 contains the starting address of the array of strings,
#    where each string occupies up to MAX_WORD_LEN chars.
# $a1 contains the starting index for the partition
# $a2 contains the ending index for the partition
# $v0 contains the index that is to be returned by the
#    partition algorithm
#

FUNCTION_PARTITION:

	# Save $s0, s1, s2
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s6, 12($sp)
	
	move $s6, $ra
	
	# s0 = pivot
	add $s3, $a1, $a2		# s3 = hi + lo
	srl $s3, $s3, 1			# s3 = (hi + lo ) / 2
	move $a3, $s3

	jal MOVE_PTR			

	move $s3, $v1			# s3->A[pivot]			
	
	subi $s1, $a1, 1		# s1 (i) = lo - 1
	addi $s2, $a2, 1		# s2 (j) = hi + 1
FOREVER:	
L1:
	addi $s1, $s1, 1		# i++
	move $a3, $s1			# a3 = index 

	jal MOVE_PTR
	move $s4, $v1			# s4->A[i]

	
	move $a0, $s4
	move $a1, $s3

	jal FUNCTION_STRCMP		# strcmp (A[i], A[pivot])

	
	blt $v0, $zero, L1		# A[i] < A[pivot]
L2:	
	subi $s2, $s2, 1		# j--
	move $a3, $s2	
	
	jal MOVE_PTR			# move_ptr (&A, j)
	move $s5, $v1			# s5->A[j]

	
	move $a0, $s3
	move $a1, $s5
	
	
	jal FUNCTION_STRCMP		# strcmp (A[pivot], A[j]) 
	
	blt $v0, $zero, L2		# A[j] > A[pivot]
	
	bge $s1, $s2, DONE
	
	# swap
	move $a0, $s4
	move $a1, $s5
	li $a2, MAX_WORD_LEN
	
	jal FUNCTION_SWAP
	
	j FOREVER
	
DONE:
	move $ra, $s6
	move $v0, $s2					
	lw $s0, 0($sp)				
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s6, 12($sp)
	addi $sp, $sp, 16

	jr $ra
	
	
#
# $a0 contains the starting address of the array of strings,
#    where each string occupies up to MAX_WORD_LEN chars.
# $a1 contains the starting index for the quicksort
# $a2 contains the ending index for the quicksort
#
# THIS FUNCTION MUST BE WRITTEN IN A RECURSIVE STYLE.
#

FUNCTION_HOARE_QUICKSORT:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	
	move $s0, $a0			#s0->A
	move $s1, $a1			# s1 = lo
	move $s2, $a2			# s2 = hi
	
	move $s6, $ra 			# save return address.
	
	bge $s1, $s2,  SORTED		# lo >= hi - done
	jal FUNCTION_PARTITION		# v0 = partition(A, lo, hi)

	
	move $a0, $s0
	move $a1, $s1
	move $a2, $v0			# hi = p

	jal FUNCTION_HOARE_QUICKSORT	# quicksort(A, lo, p)

	
	move $a0, $s0
	move $a1, $v0			# lo = p
	addi $a1, $a1, 1		# lo = p + 1
	move $a2, $s2			# restore hi = hi

	jal FUNCTION_HOARE_QUICKSORT	# v0 = partition(A, p + 1, hi)
	move $ra, $s6

SORTED:
	lw $s0, 0($sp)			
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra
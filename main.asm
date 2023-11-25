.data

BombCountStr:        .asciiz "Please enter number of bomb: "
pathFindStart:       .asciiz "Path finding start \n"
enterCol:            .asciiz "Please enter Col number: "
enterRow:            .asciiz "Please enter Row number: "
enterSecond:         .asciiz "Please enter second: "
placeBombEveryWhere: .asciiz "Place Bomb Everywhere\n"
bombExplode:         .asciiz "Bomb Explode \n"
doNothing            : .asciiz "Do nothing\n"
plantBomb            : .asciiz "Plant bomb\n"
InputCordStr:        .asciiz "Enter location of bomb: "
space_str:           .asciiz " "
newline_str:         .asciiz "\n"
currSecond:          .asciiz "  Current Second\n"

state:               .asciiz "--------------\n"
Matrix:              .space 1000
row:                 .word 10
col:                 .word 10
second:              .word 10
MatrixSize:          .word 1
BombCount:           .word 3
InputArray:          .word 1000

.text

main:
    #  Print "Please enter seconds"
    la $a0, enterSecond
    li $v0, 4
    syscall

    #  Read seconds from user input
    li $v0, 5
    syscall
    sw $v0, second

    #  Print "Please enter BombCount"
    la $a0, BombCountStr
    li $v0, 4
    syscall

    #  Read BombCount from user input
    li $v0, 5
    syscall
    sw $v0, BombCount

    #  Print "Please enter Col number"
    la $a0, enterCol
    li $v0, 4
    syscall

    #  Read col from user input
    li $v0, 5
    syscall
    sw $v0, col

    #  Print "Please enter Row number"
    la $a0, enterRow
    li $v0, 4
    syscall

    #  Read row from user input
    li $v0, 5
    syscall
    sw $v0, row

    #  Calculate MatrixSize
    lw $t1, row
    lw $t2, col
    mul $t3, $t1, $t2
    sw $t3, MatrixSize

    # Your code continues here...

    #  Print "Please enter number of bomb"
    la $a0, BombCountStr
    li $v0, 4
    syscall


    jal TakeInputs
   

    jal FillMatrix
    jal PrintMatrix

    la $a0, plantBomb
    li $v0, 4
    syscall

    jal PlantBomb
    jal PrintMatrix

    lw $a1, second
    li $a2, 1

main_loop:
  # i seperate state by state here
    la  $a0, state
    li  $v0, 4
    syscall
    la  $a0, doNothing
    li  $v0, 4
    syscall
    jal PrintMatrix
    addi $a2 ,$a2,1
    beq $a2 ,$a1 ,main_loop_end

    la  $a0, state
    li  $v0, 4
    syscall
    la  $a0, placeBombEveryWhere
    li  $v0, 4
    syscall
    jal PlantBombAllPlace
    jal PrintMatrix
    addi $a2 ,$a2,1
    beq $a2 ,$a1 ,main_loop_end

    la  $a0, state
    li  $v0, 4
    syscall
    la  $a0, bombExplode
    li  $v0, 4
    syscall
    jal ExplodeBomb
    jal PrintMatrix
    jal OtoX
    addi $a2 ,$a2,1
    bne $a2 ,$a1 ,main_loop
  
main_loop_end:
    la  $a0, pathFindStart
    li  $v0, 4
    syscall
    jal FindPath
    jal PrintMatrix
    j   Exit

Exit:
    li $v0, 10
    syscall
FindPath:
    la $s0, Matrix      # Matrix'in adresini $s0'a yükle
    la $s7, Matrix
    lw $s1, MatrixSize
    lw $t5, MatrixSize
    lw $s2, row
    lw $s3, col

    li $s4, 0           # right
    li $s5, 0           # down

    li $s6, 0           # curr index

    li $t0, 0           # curr row
    li $t1, 0           # curr col

    li $t7, 46           # Load the ASCII code for '.' into $t7
    li $t6, 112          # Load the ASCII code for 'P' into $t6
    lb $t2, 0($s7)

    #  Check if it is a dot
    bne $t7, $t2, find_path_done
    sb $t6, 0($s7)

  

find_path_loop:
    # Calculate right index
    addi $s4, $s6, 1
    addi $t1, $t1, 1 #current col

    # Calculate down index
    add $s5, $s6, $s3

    # Check if right index is within bounds
    bne $t1, $s3, look_right #cur col less then col
    j look_down

look_right:
    #  Take the right byte
    add $s7, $s4, $s0
    lb $t2, 0($s7)

    # Check if it is a dot
    bne $t7, $t2, look_down

    #  Change it to 'P'
    sb $t6, 0($s7)
   
    addi $s6, $s6, 1
    bne $s6 , $t5 ,find_path_loop
  

look_down:
    # Check if down index is within bounds
     addi $t0, $t0, 1
      subi $t1, $t1, 1
    bge $t0, $s2, find_path_done

    #  Take the down byte
    add $s7, $s5, $s0
    lb $t2, 0($s7)

    # Check if it is a dot
    bne $t7, $t2, find_path_done

    #  Change it to 'P'
    sb $t6, 0($s7)
   
    add $s6, $s6, $s3
    bne $s6 , $t5 ,find_path_loop
   
find_path_done:
    jr $ra

 

OtoX:
    la $s0, Matrix
    lw $s1, MatrixSize
    li $t5, 88           # ASCII kodu 'X'
    li $t6, 79           # ASCII kodu 'O'

OtoX_loop:


    addi $t0, $zero, 0   # counter

OtoX_inner_loop:
    bge $t0, $s1, OtoX_end   # if counter eq to last index

    lb $t1, 0($s0)

    # change 'O' by 'X'
    beq $t1, $t6, Change_O_to_X

    OtoX_continue:
    addi $s0, $s0, 1       # look next index
    addi $t0, $t0, 1       # add 1 counter
    j OtoX_inner_loop

Change_O_to_X:
    sb $t5, 0($s0)         # change with  'X'
    j  OtoX_continue

OtoX_end:
jr $ra
ExplodeBomb:
 
   la $s0, Matrix
   la $t9, Matrix
   lw $s1, MatrixSize
   lw $s2, row
   lw $s3, col
   li $t0, 0
   subi $t2,$s3,1  #this help to check boundry when last column
   li $t5, 88            # Load the ASCII code for 'X'
   li $t6, 79           # Load the ASCII code for 'O'
   li $t7, 46           # Load the ASCII code for '.'

   li $s7, 0   #Nort index
   li $s6, 0   #East
   li $s5, 0    #West
   li $s4, 0    #South

   subi $t0 , $t0 ,1 #start frrom - 1 because confusion at loop
   subi $s0 , $s0 ,1
   explode_loop: beq $t0 ,$s1 ,explode_done
   addi $t0 , $t0 ,1
   addi $s0 , $s0 ,1
   lb $t1, 0($s0)
   bne $t1, $t5 ,explode_loop
  
   sb $t7, 0($s0)
  
   divu $t8, $t0, $s3   # Divide the current index by the number of columns
   mflo $t4             # Quotient is the row number
   mfhi $t3            # Remainder is the column number

   look_north:

   la $t9, Matrix

   beq $t4 , $zero , look_east # if row number 0 dont look because tehre is no up
   sub $s7, $t0, $s3 #indexten  col sayısı kadar çık üsttekini buk
   add $t9, $t9 ,$s7
   lb $t1, 0($t9)
   bne $t1 ,$t6 ,look_east #if it is not O jump
   sb $t7, 0($t9)

   look_east:
   #HATA BURADA
   la    $t9, Matrix
   beq $t3 , $t2 , look_west # if col number max col dont look because there is no right
   addi $s6 , $t0 ,1
   add $t9, $t9 ,$s6

   lb $t1, 0($t9)
   bne $t1 ,$t6 ,look_west #if it is not O jump
   sb $t7, 0($t9)


   look_west:
   la $t9, Matrix
    beq $t3 , $zero , look_south # if col number 0 dont look because there is no left
    subi $s5 , $t0 ,1
    add $t9, $t9 ,$s5
    lb $t1, 0($t9)
    bne $t1 ,$t6 ,look_south #if it is not O jump
    sb $t7, 0($t9)
    look_south:
    la $t9, Matrix
    beq $t4 , $s2 ,explode_loop
    add $s4, $t0, $s3
    add $t9, $t9 ,$s4
    lb $t1, 0($t9)
    bne $t1 ,$t6 ,explode_loop #if it is not O jump
    sb $t7, 0($t9)
    j  explode_loop

explode_done:
    jr $ra  # Return from the function


PlantBombAllPlace:
   
    lw $s1, MatrixSize   # Load the size of the matrix into $s0
    la $s0, Matrix       # Load the address of the matrix into $s0
    li $t4, 88            # Load the ASCII code for 'X'
    li $t3, 79           # Load the ASCII code for 'O'
    li $t2, 46           # Load the ASCII code for '.'
    
    li $t0, 0      # Initialize a loop counter to 0
  addi $s0, $s0, -1
plant_bomb_all_place_loop:
    beq $t0, $s1, plant_bomb_all_place_end  # If $t0 equals $s0 (end of the matrix), exit the loop
    addi $s0, $s0, 1
    addi $t0, $t0, 1     # Increment the loop counter
         # Move to the next element in the matrix

    lb $t1, 0($s0)       # Load the byte (character) from the current matrix element
   
     # If the current character is not '.', continue the loop
    beq  $t1, $t4, plant_bomb_all_place_loop
    sb $t3, 0($s0)       # Store the byte (ASCII code for 'O') in place of the '.' character
     
    j plant_bomb_all_place_loop  # Jump back to the beginning of the loop

plant_bomb_all_place_end:
    jr $ra               # Return from the function


PlantBomb:
    #  Load addresses of variables into registers
    la $s7, InputArray     # Load the memory address of InputArray into $s7
    la $s6, BombCount      # Load the memory address of BombCount into $s6
    la $s2, Matrix         # Load the memory address of Matrix into $s2


    lw $s5, 0($s6)         # Load the value at BombCount's address into $s5

plant_loop:
    # Check if we have planted all bombs
    beq $s5, $zero, plant_end

    #  Load the current bomb index from InputArray
    lw $t8, 0($s7)

    # Add the base address of the Matrix to get the actual address
    add $t9, $s2, $t8

    #  Store 'X' character
    li $t0, 88              # ASCII value for 'X'
    sb $t0, 0($t9)

    # Move to the next bomb index in InputArray
    addi $s7, $s7, 4

    # Decrement the bomb count
    sub $s5, $s5, 1

    # Repeat the loop
    j plant_loop

plant_end:
   
    jr $ra
FillMatrix:
    #  Load the size of the matrix (number of rows or columns) from memory
    lw $t1, MatrixSize
#  Load the base address of Matrix into $s3
la $s3, Matrix

#  Initialize a counter for the loop
li $t0, 0
li $t3, 46
fill_loop:
    # Check if we have filled all elements
    beq $t0, $t1, fill_done

    #  Store the ASCII value for '0' in the current element
    sb $t3, 0($s3)

    # Move to the next element in the matrix (word-aligned)
    addi $s3, $s3, 1  # Move by 4 bytes (word size)

    # Increment the counter
    addi $t0, $t0, 1

    # Repeat the loop
    j fill_loop


fill_done:
    jr $ra
PrintMatrix:
    #  Load the base address of the matrix into $s0
    la $s0, Matrix

    #  Load the row and col values from memory
    lw $t1, row
    lw $t2, col

    #  Initialize loop counters for rows and columns
    li $t4, 1  # Initialize column counter
    li $t0, 0  # index
    lw $t7, MatrixSize

print_loop:
    # Check if the row counter (t3) is equal to the number of rows (t1)
    beq $t0, $t7, print_done
    addi $t0, $t0, 1

    lb $a0, 0($s0)

    # Check if the current character is 'X', if yes, print 'O' instead
    li $t9,       'X'
    beq $a0, $t9, print_O
    #  Otherwise, print the original character
    li $v0,       11
    syscall
    j  print_continue

print_O:
    #  Print 'O' character
    li $v0, 11
    li $a0, 'O'
    syscall

print_continue:
    # Check if the column counter (t4) is equal to the number of columns (t2)
    addi $s0, $s0, 1
    beq $t4, $t2, print_newline
    addi $t4, $t4, 1

    j print_loop

print_newline:
    #  Print a newline character
    li $v0, 11
    li $a0, 10  # ASCII value for newline
    syscall
    #  Reset the column counter
    li $t4, 1
    #  Repeat the loop
    j  print_loop

print_done:
    jr $ra  # Return from the function

TakeInputs:
    #  Load the base address of InputArray into $s1
    la $s1, InputArray
    
    #  Load BombCount from memory into $t6
    lw $t6, BombCount

    #  Initialize a counter for the loop
    li $t0, 0

input_loop:
    # Check if the counter (t0) is equal to BombCount (t6)
    beq $t0, $t6, input_done

    #  Print the prompt for input
    la $a0, InputCordStr
    li $v0, 4
    syscall

    #  Read an integer from the user
    li $v0, 5
    syscall

    #  Store the input value in the array at s1
    sw $v0, 0($s1)

    # Move to the next element in the array
    addi $s1, $s1, 4

    # Increment the counter
    addi $t0, $t0, 1

    # Repeat the loop
    j input_loop

input_done:
    jr $ra

   

##################################################
# Testbench for ALU arith and comp instructions
##################################################

##################################################
# EXECUTION:
# r0 = 0
# r1 = 2
# r2 = 1
# r3 = -2
# r4 = -1
# r5 = 3
# r6 = 4 
# r7 = 0
# r8 = 1
# r9 = 1
# r10 = 0
# r11 = 1
# r12 = 1
# r13 = 0
# r14 = 0
# r15 = 1
# r16 = 0
# r17 = 1
# r18 = 1
# r19 = 0
# r20 = 0
# r21 = 0
# r22 = 1
# r23 = 0
# r24 = 1
# r25 = 1
# r26 = 1
# r27 = 1
# r28 = 1
##################################################
    
addi r1, r0, #2 
subi r2, r1, #1
addi r3, r1, #-4
subi r4, r3, #-1
add r5, r1, r2
sub r6, r5, r4

seqi r7, r0, #-1
snei r8, r1, #1
seqi r9, r5, #3
snei r10, r3, #-2
seq r11, r8, r9
sne r12, r3, r1

slti r13, r6, #4
sgti r14, r6, #6
slei r15, r6, #4
sgei r16, r6, #6
sltui r17, r0, #-4
sgtui r18, r3, #6
sleui r19, r3, #2
sgeui r20, r6, #6

slt r21, r6, r8
sgt r22, r6, r9
sle r23, r6, r3
sge r24, r6, r2
sltu r25, r0, r8
sgtu r26, r3, r9
sleu r27, r3, r3
sgeu r28, r6, r2



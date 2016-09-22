##################################################
# Testbench for jal instruction
##################################################

addi r1, r1, #5
addi r2, r2, #5

jal stop

subi r1, r1, #5
subi r2, r2, #5

stop:
j stop



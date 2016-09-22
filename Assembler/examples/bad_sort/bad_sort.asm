##################################################
# NOTE:
# Registers:
# r1: loop index
# r2: operand 1
# r3: operand 2
# r4: operand camparison result 
# r5: index comparison result
# r6: fail count
# r7: fail comparison result
##################################################

find:
# Load from memory
lw r2, (r1)
lw r3, 4(r1)
sge r4, r3, r2
# If the order is okay, move to next step ... 
bnez r4, next_step
# ... If order is bad, swap memory content
sw (r1), r3
sw 4(r1), r2
addi r6, r6, #1
j next_step

next_step:
# Increment the value for the iteration
addi r1, r1, #4
# Check if we reached the end of the memory (1024 bytes, 256 words)
seqi r5, r1, #1020
bnez r5, next_cycle
j find

next_cycle:
# Failed comparisons must be zero
beqz r6, end
# Clear the index values
sub r1, r1, r1
sub r6, r6, r6
j find

end:
# Loop forever
j end

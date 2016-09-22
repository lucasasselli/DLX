##################################################
# Fibonacci's number generator
##################################################

# Setup the first two numbers
addi r1,r2,#1
addi r2,r2,#1

loop:
# Compute next number and store it
add r3,r1,r2
sw 0(r4), r3

# Swap numbers: n-1=n, n=n+1
addi r1,r2,#0
addi r2,r3,#0

# Increment memory pointer, decrement counter
addi r4,r4,#4
seqi r5,r4,#120
beqz r5, loop

# Loop forever
end:
j end

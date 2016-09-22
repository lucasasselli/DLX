# DLX

This is my final project for the Microelectronic systems course at the Polytechnic University of Turin.

## Instruction set

|General instructions | Register-Register instructions|
|:-------------------:|:-----------------------------:| 
| j 		      | 			sll|
|jal | srl|
|beqz | sra|
|bnez | add|
|addi | sub|
|subi | and|
|andi | or|
|ori | xor|
|xori | seq|
|nop | sne|
|seqi | slt|
|snei | sgt|
|slti | sle|
|sgti | sge|
|slei | sltu|
|sgei | sgtu|
|lw | sleu|
|sw | sgeu|
|sltui | |
|sgtui | |
|sleui | |
|sgeui | |
|slli | |
|srli | |
|srai | |

## TODO

 - Branch prediction
 - Long latency operations
 - Double and float support

## How to use it
The DLX has been tested with *Modelsim ALTERA EDITION 10.4d* (other version of Modelsim should work too). To compile the project:

    make init
    make

A simple testbench can be found in the folder "Testbench/dlx". The two memories are preloaded with the content of the files "iram" and "dram".
To compile a program and load it into the testbench:

	cd Assembler
	sh assembler.sh [path_to_asm_file].asm
	mv iram ../Testbench/dlx/.
		
Example programs are available in the folder "Assembler/examples". 






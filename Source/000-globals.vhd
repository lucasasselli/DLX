library ieee;
use ieee.std_logic_1164.all;

-- NOTE: These constants are NOT design parameters, changing these values may compromise the project.

package GLOBALS is

    --------------------------------------------------
    -- Constants
    --------------------------------------------------

    constant WORD_SIZE_c : integer := 32; -- Word size
    constant FUNC_SIZE_c : integer := 11; -- Func field size for R-Type Ops
    constant OPC_SIZE_c : integer := 6; -- OP code field size
    constant IMM26_SIZE_c : integer := 26;
    constant IMM16_SIZE_c : integer := 16;

    constant RF_SIZE_c : integer := 32; -- Register file size (words)
    constant RF_ADDR_SIZE_c : integer := 5; -- Register file address size

    constant DRAM_SIZE_c : integer := 1024; -- DRAM size (bytes)
    constant DRAM_ADDR_SIZE_c : integer := 10; -- DRAM address size

    constant IRAM_SIZE_c : integer := 1024; -- IRAM size (bytes)
    constant IRAM_ADDR_SIZE_c : integer := 26; -- IRAM address size

    -- Alu
    constant ADDER_CARRY_SIZE_c : integer := 4;
    constant ADDER_CARRY_NUMBER_c : integer := 8;
    constant SHIFT_VAL_SIZE_c : integer := 5;
    constant SHIFT_MASK_NUMBER_c : integer := 8;
    constant SHIFT_MASK_OFFSET_c : integer := 4;
    constant SHIFT_SLICE_NUMBER_c : integer := 4;
    constant SHIFT_COARSE_SIZE_c : integer := 3;
    constant SHIFT_FINE_SIZE_c : integer := 2;

    -- Others 
    constant BIT_SIZE_c : integer := 1; -- Size of one bit
    constant BYTE_SIZE_c : integer := 8; -- Size of one byte
    constant LINK_ADDR_c : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0) := "11111"; -- Link address (r31)
    constant PC_INCR_c : std_logic_vector(WORD_SIZE_c-1 downto 0) := "00000000000000000000000000000100"; -- PC increment


    --------------------------------------------------
    -- Control word
    --------------------------------------------------

    constant CTRL_S1_SIZE_c : integer := 0;
    constant CTRL_S2_SIZE_c : integer := 8;
    constant CTRL_S3_SIZE_c : integer := 2;
    constant CTRL_S4_SIZE_c : integer := 4;
    constant CTRL_S5_SIZE_c : integer := 1;

    constant CTRL_SIZE_c : integer := CTRL_S1_SIZE_c + CTRL_S2_SIZE_c + CTRL_S3_SIZE_c + CTRL_S4_SIZE_c + CTRL_S5_SIZE_c;

    -- S1 control signals
    -- NOTE: S1 is not controlled with the control word

    -- S2 control signals
    constant CTRL_S2_EN : integer := 14; -- Latch enable
    constant CTRL_S2_RF_A_EN : integer := 13; -- RF read port A enable
    constant CTRL_S2_RF_B_EN : integer := 12; -- RF read port B enable
    constant CTRL_S2_JUMP_EN : integer := 11; -- Jump enable
    constant CTRL_S2_BRANCH_EN : integer := 10; -- Branch enable
    constant CTRL_S2_BRANCH_COND : integer := 9; -- Branch condition (0: Not zero, 1: Zero);
    constant CTRL_S2_LINK_EN : integer := 8; -- Link enable
    constant CTRL_S2_WBA_SEL : integer := 7; -- Writeback address selection (O: I-type, 1: R-type);

    -- S3 control signals
    constant CTRL_S3_EN : integer := 6; -- Latch enable
    constant CTRL_S3_B_SEL : integer := 5; -- MUX B selection (0: I-type, 1: R-Type);

    -- S4 control signals
    constant CTRL_S4_EN : integer := 4; -- Latch enable
    constant CTRL_S4_DRAM_RD_EN : integer := 3; -- DRAM read enable
    constant CTRL_S4_DRAM_WR_EN : integer := 2; -- DRAM write enable
    constant CTRL_S4_WB_SEL : integer := 1; -- Writeback MUX selection (0: ALU, 1: DRAM);

    -- S5 control signals
    constant CTRL_S5_RF_WR_EN : integer := 0; -- RF write enable

    -- Microcode
    constant CTRL_MEM_SIZE_c : integer := 63; -- Microcode Memory Size

    type CTRL_MEM_t is array (integer range 0 to CTRL_MEM_SIZE_c - 1) of std_logic_vector(CTRL_SIZE_c-1 downto 0);

    signal CTRL_MEM : CTRL_MEM_t := (
    "111000011110001", -- (0x00) Rtype
    "000000000000000", -- (0x01)
    "000100000000000", -- (0x02) J
    "000100100000000", -- (0x03) JAL
    "110011000000000", -- (0x04) BEQZ
    "110010000000000", -- (0x05) BNEZ
    "000000000000000", -- (0x06)
    "000000000000000", -- (0x07)
    "110000001010001", -- (0x08) ADDI
    "000000000000000", -- (0x09)
    "110000001010001", -- (0x0a) SUBI
    "000000000000000", -- (0x0b)
    "110000001010001", -- (0x0c) ANDI
    "110000001010001", -- (0x0d) ORI
    "110000001010001", -- (0x0e) XORI
    "000000000000000", -- (0x0f)
    "000000000000000", -- (0x10)
    "000000000000000", -- (0x11)
    "000000000000000", -- (0x12)
    "000000000000000", -- (0x13)
    "110000001010001", -- (0x14) SLLI
    "000000000000000", -- (0x15) NOP
    "110000001010001", -- (0x16) SRLI
    "110000001010001", -- (0x17) SRAI
    "110000001010001", -- (0x18) SEQI
    "110000001010001", -- (0x19) SNEI
    "110000001010001", -- (0x1a) SLTI
    "110000001010001", -- (0x1b) SGTI
    "110000001010001", -- (0x1c) SLEI
    "110000001010001", -- (0x1d) SGEI
    "000000000000000", -- (0x1e)
    "000000000000000", -- (0x1f)
    "000000000000000", -- (0x20)
    "000000000000000", -- (0x21)
    "000000000000000", -- (0x22)
    "110000001011011", -- (0x23) LW
    "000000000000000", -- (0x24)
    "000000000000000", -- (0x25)
    "000000000000000", -- (0x26)
    "000000000000000", -- (0x27)
    "000000000000000", -- (0x28)
    "000000000000000", -- (0x29)
    "000000000000000", -- (0x2a)
    "111000001000100", -- (0x2b) SW
    "000000000000000", -- (0x2c)
    "000000000000000", -- (0x2d)
    "000000000000000", -- (0x2e)
    "000000000000000", -- (0x2f)
    "000000000000000", -- (0x30)
    "000000000000000", -- (0x31)
    "000000000000000", -- (0x32)
    "000000000000000", -- (0x33)
    "000000000000000", -- (0x34)
    "000000000000000", -- (0x35)
    "000000000000000", -- (0x36)
    "000000000000000", -- (0x37)
    "000000000000000", -- (0x38)
    "000000000000000", -- (0x39)
    "110000001010001", -- (0x3a) SLTUI
    "110000001010001", -- (0x3b) SGTUI
    "110000001010001", -- (0x3c) SLEUI
    "110000001010001", -- (0x3d) SGEUI
    "000000000000000"); 

    --------------------------------------------------
    -- Status word
    --------------------------------------------------

    constant STAT_SIZE_c : integer := 5;

    constant STAT_BRANCH_FLAG : integer := 4;
    constant STAT_S3_A_MATCH : integer := 3;
    constant STAT_S4_A_MATCH : integer := 2;
    constant STAT_S3_B_MATCH : integer := 1;
    constant STAT_S4_B_MATCH : integer := 0;

    --------------------------------------------------
    -- AOP
    --------------------------------------------------

    constant AOP_SIZE_c : integer := 5;

    constant AOP_NOP : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00000";
    constant AOP_ADD : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00001";
    constant AOP_SUB : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00010";
    constant AOP_AND : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00011";
    constant AOP_OR : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00100";
    constant AOP_XOR : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00101";
    constant AOP_SLL : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00110";
    constant AOP_SRL : std_logic_vector(AOP_SIZE_c-1 downto 0) := "00111";
    constant AOP_SRA : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01000";
    constant AOP_SEQ : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01001";
    constant AOP_SNE : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01010";
    constant AOP_SLT : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01011";
    constant AOP_SGT : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01100";
    constant AOP_SLE : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01101";
    constant AOP_SGE : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01110";
    constant AOP_SLTU : std_logic_vector(AOP_SIZE_c-1 downto 0) := "01111";
    constant AOP_SGTU : std_logic_vector(AOP_SIZE_c-1 downto 0) := "10000";
    constant AOP_SLEU : std_logic_vector(AOP_SIZE_c-1 downto 0) := "10001";
    constant AOP_SGEU : std_logic_vector(AOP_SIZE_c-1 downto 0) := "10010";

    constant ACTRL_SIZE_c : integer := 13;

    -- Result selection
    constant ACTRL_RES1 : integer := 12;
    constant ACTRL_RES0 : integer := 11;

    -- Arithmetical 
    constant ACTRL_SUB_EN : integer := 10;

    -- Logical
    constant ACTRL_LOGIC_SEL3 : integer := 9;
    constant ACTRL_LOGIC_SEL2 : integer := 8;
    constant ACTRL_LOGIC_SEL1 : integer := 7;
    constant ACTRL_LOGIC_SEL0 : integer := 6;

    -- Shift
    constant ACTRL_SHIFT_SEL1 : integer := 5;
    constant ACTRL_SHIFT_SEL0 : integer := 4;

    -- Comparison
    constant ACTRL_COMP_RES1 : integer := 3;
    constant ACTRL_COMP_RES0 : integer := 2; 
    constant ACTRL_COMP_STRICT : integer := 1;
    constant ACTRL_COMP_SIGN : integer := 0;


    constant ACTRL_MEM_SIZE_c : integer := 19; -- Microcode Memory Size

    type ACTRL_MEM_t is array (integer range 0 to ACTRL_MEM_SIZE_c - 1) of std_logic_vector(ACTRL_SIZE_c-1 downto 0);

    signal ACTRL_MEM : ACTRL_MEM_t := (
    "0000000000000", -- NOP
    "0000000000000", -- ADD
    "0010000000000", -- SUB
    "0101000000000", -- AND
    "0101110000000", -- OR
    "0100110000000", -- XOR
    "1000000000000", -- SLL
    "1000000100000", -- SRL
    "1000000110000", -- SRA
    "1110000000000", -- SEQ
    "1110000000100", -- SNE
    "1110000001111", -- SLT 
    "1110000001011", -- SGT
    "1110000001101", -- SLE
    "1110000001001", -- SGE
    "1110000001110", -- SLTU
    "1110000001010", -- SGTU
    "1110000001100", -- SLEU
    "1110000001000"); -- SGEU

    --------------------------------------------------
    -- Forward 
    --------------------------------------------------

    constant FWD_SIZE_c : integer := 4;

    constant FWD_A_EN : integer := 3;
    constant FWD_A_SEL : integer := 2;
    constant FWD_B_EN : integer := 1;
    constant FWD_B_SEL : integer := 0;

    --------------------------------------------------
    -- Instruction encoding
    --------------------------------------------------

    -- IR Fields
    constant FIELD_OP_UPPER_c : integer := 31;
    constant FIELD_OP_LOWER_c : integer := 26;
    constant FIELD_RA_UPPER_c : integer := 25;
    constant FIELD_RA_LOWER_c : integer := 21;
    constant FIELD_RB_UPPER_c : integer := 20;
    constant FIELD_RB_LOWER_c : integer := 16;
    constant FIELD_RD_I_UPPER_c : integer := 20;
    constant FIELD_RD_I_LOWER_c : integer := 16;
    constant FIELD_RD_R_UPPER_c : integer := 15;
    constant FIELD_RD_R_LOWER_c : integer := 11;
    constant FIELD_IMM26_UPPER_c : integer := 25;
    constant FIELD_IMM26_LOWER_c : integer := 0;
    constant FIELD_IMM16_UPPER_c : integer := 15;
    constant FIELD_IMM16_LOWER_c : integer := 0;

    -- OP code field
    constant OPC_R : std_logic_vector(OPC_SIZE_c-1 downto 0) := "000000"; -- (0x00)
    constant OPC_BEQZ : std_logic_vector(OPC_SIZE_c-1 downto 0) := "000100"; -- (0x04)
    constant OPC_BNEZ : std_logic_vector(OPC_SIZE_c-1 downto 0) := "000101"; -- (0x05)
    constant OPC_ADDI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "001000"; -- (0x08)
    constant OPC_SUBI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "001010"; -- (0x0a)
    constant OPC_ANDI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "001100"; -- (0x0c)
    constant OPC_ORI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "001101"; -- (0x0d)
    constant OPC_XORI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "001110"; -- (0x0e)
    constant OPC_SLLI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "010100"; -- (0x14)
    constant OPC_NOP : std_logic_vector(OPC_SIZE_c-1 downto 0) := "010101"; -- (0x15)
    constant OPC_SRLI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "010110"; -- (0x16)
    constant OPC_SRAI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "010111"; -- (0x17)
    constant OPC_SEQI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "011000"; -- (0x18)
    constant OPC_SNEI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "011001"; -- (0x19)
    constant OPC_SLTI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "011010"; -- (0x1a)
    constant OPC_SGTI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "011011"; -- (0x1b)
    constant OPC_SLEI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "011100"; -- (0x1c)
    constant OPC_SGEI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "011101"; -- (0x1d)
    constant OPC_LW : std_logic_vector(OPC_SIZE_c-1 downto 0) := "100011"; -- (0x23)
    constant OPC_SW : std_logic_vector(OPC_SIZE_c-1 downto 0) := "101011"; -- (0x2b)
    constant OPC_SLTUI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "111010"; -- (0x3a)
    constant OPC_SGTUI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "111011"; -- (0x3b)
    constant OPC_SLEUI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "111100"; -- (0x3c)
    constant OPC_SGEUI : std_logic_vector(OPC_SIZE_c-1 downto 0) := "111101"; -- (0x3d)

    -- R-type function field
    constant FUNC_SLL : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000000100"; -- (0x04)
    constant FUNC_SRL : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000000110"; -- (0x06)
    constant FUNC_SRA : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000000111"; -- (0x07)
    constant FUNC_ADD : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000100000"; -- (0x20)
    constant FUNC_SUB : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000100010"; -- (0x22)
    constant FUNC_AND : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000100100"; -- (0x24)
    constant FUNC_OR : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000100101"; -- (0x25)
    constant FUNC_XOR : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000100110"; -- (0x26)
    constant FUNC_SEQ : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000101000"; -- (0x28)
    constant FUNC_SNE : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000101001"; -- (0x29)
    constant FUNC_SLT : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000101010"; -- (0x2a)
    constant FUNC_SGT : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000101011"; -- (0x2b)
    constant FUNC_SLE : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000101100"; -- (0x2c)
    constant FUNC_SGE : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000101101"; -- (0x2d)
    constant FUNC_SLTU : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000111010"; -- (0x3a)
    constant FUNC_SGTU : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000111011"; -- (0x3b)
    constant FUNC_SLEU : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000111100"; -- (0x3c)
    constant FUNC_SGEU : std_logic_vector(FUNC_SIZE_c-1 downto 0) := "00000111101"; -- (0x3d)
end GLOBALS;

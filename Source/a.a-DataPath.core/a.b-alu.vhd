library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.globals.all;

entity ALU is
    port (
        A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
        RES : out std_logic_vector(WORD_SIZE_c-1 downto 0));
end ALU;

architecture STRUCTURAL of ALU is

    --------------------------------------------------
    -- Components declaration
    --------------------------------------------------

    -- Sparse tree adder
    component P4_ADDER is
        port ( 
            A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            C_in : in std_logic;
            S: out std_logic_vector(WORD_SIZE_c-1 downto 0);
            C_out : out std_logic
        );
    end component;

    -- Generic 4to1 multiplexer
    component MUX41_GEN is
        generic (NBIT: integer);
        port (A: in std_logic_vector(NBIT-1 downto 0) ;
              B: in std_logic_vector(NBIT-1 downto 0);
              C: in std_logic_vector(NBIT-1 downto 0);
              D: in std_logic_vector(NBIT-1 downto 0);
              SEL: in std_logic_vector(1 downto 0);
              Y: out std_logic_vector(NBIT-1 downto 0));
    end component;

    -- Generic zero comparator
    component ZERO_GEN is
        generic (NBIT: integer);
        port (
            A: in std_logic_vector(NBIT-1 downto 0);
            ZERO : out std_logic
        );
    end component;

    -- Logic unit
    component LOGIC_UNIT is
        port ( 
            A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            SEL : in std_logic_vector(3 downto 0);
            RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
        );
    end component;

    -- Shifter 
    component SHIFTER is
        port ( 
            I : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            VAL : in std_logic_vector(SHIFT_VAL_SIZE_c-1 downto 0); 
            DIR : in std_logic; -- 0: left, 1: right
            MODE : in std_logic; -- 0: logical, 1: arithmetical
            RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
        );
    end component;


    -- AOP Decoder
    component AOP_DECODER is
        port ( 
            AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
            ACTRL : out std_logic_vector(ACTRL_SIZE_c-1 downto 0)
        );
    end component;

    --------------------------------------------------
    -- Signals declaration
    --------------------------------------------------

    signal ACTRL_i : std_logic_vector(ACTRL_SIZE_c-1 downto 0);

    -- Arithmetical operations
    signal B_XOR_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal C_out_i : std_logic;

    -- Comparison operations
    signal IS_ZERO_i : std_logic;
    signal STRICT_OK_i : std_logic;
    signal SIGN_OK_i : std_logic;

    signal SIGN_A_i : std_logic;
    signal SIGN_B_i : std_logic;

    signal EQUAL_i : std_logic;
    signal NOT_EQUAL_i : std_logic;
    signal GREATER_i : std_logic;
    signal LOWER_i : std_logic;

    signal RES_COMP_BIT_i : std_logic;

    signal COMP_SEL_i : std_logic_vector(1 downto 0);

    -- Logical operations
    signal LOGIC_SEL_i : std_logic_vector(3 downto 0);

    -- Results
    signal RES_ARITH_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RES_COMP_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RES_LOGIC_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RES_SHIFT_i : std_logic_vector(WORD_SIZE_c-1 downto 0);

    signal RES_SEL_i : std_logic_vector(1 downto 0);

begin

    -- AOP decoder
    AOP_DECODER_I : AOP_DECODER
    port map (
        AOP => AOP,
        ACTRL => ACTRL_i
    );

    --------------------------------------------------
    -- Arithmetical operations
    --------------------------------------------------

    B_XOR_i <= B xor (WORD_SIZE_c-1 downto 0 => ACTRL_i(ACTRL_SUB_EN));

    ADDER : P4_ADDER
    port map (
        A => A,
        B => B_XOR_i,
        C_in => ACTRL_i(ACTRL_SUB_EN),
        S => RES_ARITH_i,
        C_out => C_out_i
    );

    --------------------------------------------------
    -- Logical operations
    --------------------------------------------------

    LOGIC_SEL_i <= ACTRL_i(ACTRL_LOGIC_SEL3) & ACTRL_i(ACTRL_LOGIC_SEL2) & ACTRL_i(ACTRL_LOGIC_SEL1) & ACTRL_i(ACTRL_LOGIC_SEL0);

    LOGIC_UNIT_I : LOGIC_UNIT
    port map (
        A => A,
        B => B,
        SEL => LOGIC_SEL_i,
        RES => RES_LOGIC_i
    );

    --------------------------------------------------
    -- Shift operations
    --------------------------------------------------

    SHIFTER_I : SHIFTER
    port map (
        I => A,
        VAL => B(SHIFT_VAL_SIZE_c-1 downto 0),
        DIR => ACTRL_i(ACTRL_SHIFT_SEL1),
        MODE => ACTRL_i(ACTRL_SHIFT_SEL0),
        RES => RES_SHIFT_i
    );

    --------------------------------------------------
    -- Comparison operations
    --------------------------------------------------

    ZERO_GEN_I : ZERO_GEN
    generic map (
        NBIT => WORD_SIZE_c)
    port map (
        A => RES_ARITH_i,
        ZERO => IS_ZERO_i
    );


    EQUAL_i <= IS_ZERO_i;
    NOT_EQUAL_i <= not(IS_ZERO_i);

    SIGN_A_i <= A(WORD_SIZE_c-1);
    SIGN_B_i <= B(WORD_SIZE_c-1);


    STRICT_OK_i <= ACTRL_i(ACTRL_COMP_STRICT) nand EQUAL_i; 
    SIGN_OK_i <= SIGN_A_i xnor SIGN_B_i;

    GREATER_i <= ((not SIGN_A_i and SIGN_B_i and ACTRL_i(ACTRL_COMP_SIGN)) or ((SIGN_OK_i or not ACTRL_i(ACTRL_COMP_SIGN)) and C_out_i)) 
                 and STRICT_OK_i;
    LOWER_i <= ((SIGN_A_i and not SIGN_B_i and ACTRL_i(ACTRL_COMP_SIGN)) or (((SIGN_OK_i or not ACTRL_i(ACTRL_COMP_SIGN)) and not C_out_i) or IS_ZERO_i)) 
               and STRICT_OK_i;

    COMP_SEL_i <= ACTRL_i(ACTRL_COMP_RES1) & ACTRL_i(ACTRL_COMP_RES0);

    MUX_COMP : MUX41_GEN
    generic map (
        NBIT => 1)
    port map (
        A(0) => EQUAL_i,
        B(0) => NOT_EQUAL_i,
        C(0) => GREATER_i,
        D(0) => LOWER_i,
        SEL => COMP_SEL_i,
        Y(0) => RES_COMP_BIT_i);

    RES_COMP_i <= (WORD_SIZE_c-1 downto 1 => '0') & RES_COMP_BIT_i;

    -- Output multiplexer 
    RES_SEL_i <= ACTRL_i(ACTRL_RES1) & ACTRL_i(ACTRL_RES0);

    MUX_OUT : MUX41_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        A => RES_ARITH_i,
        B => RES_LOGIC_i,
        C => RES_SHIFT_i,
        D => RES_COMP_i,
        SEL => RES_SEL_i,
        Y => RES);

end STRUCTURAL;

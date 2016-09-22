library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity SHIFTER is
    port ( 
        I : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        VAL : in std_logic_vector(SHIFT_VAL_SIZE_c-1 downto 0); 
        DIR : in std_logic; -- 0: left, 1: right
        MODE : in std_logic; -- 0: logical, 1: arithmetical
        RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
    );
end SHIFTER;

architecture BEHAVIOURAL of SHIFTER is

    constant SHIFT_MASK_SIZE_c : integer := WORD_SIZE_c+SHIFT_MASK_OFFSET_c;
    constant SHIFT_COARSE_UPPER_c : integer := SHIFT_VAL_SIZE_c-1;
    constant SHIFT_COARSE_LOWER_c : integer := SHIFT_VAL_SIZE_c-SHIFT_COARSE_SIZE_c;
    constant SHIFT_FINE_UPPER_c : integer := SHIFT_COARSE_LOWER_c-1;
    constant SHIFT_FINE_LOWER_c : integer := 0;

    signal FILL_i : std_logic;
    signal COARSE_i : std_logic_vector(SHIFT_MASK_SIZE_c-1 downto 0);
    signal COARSE_SEL_i : std_logic_vector(SHIFT_COARSE_SIZE_c-1 downto 0);
    signal FINE_SEL_i : std_logic_vector(SHIFT_FINE_SIZE_c-1 downto 0);

    type MASK_ARRAY_t is array (0 to SHIFT_MASK_NUMBER_c-1) of std_logic_vector(SHIFT_MASK_SIZE_c-1 downto 0);
    type SLICE_ARRAY_t is array (0 to SHIFT_SLICE_NUMBER_c-1) of std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal MASK_i : MASK_ARRAY_t;
    signal SLICE_i : SLICE_ARRAY_t;
begin

    FILL_i <= I(WORD_SIZE_c-1) and MODE;

    -- Mask generation
    MASK_LOOP : for K in 0 to SHIFT_MASK_NUMBER_c-1 generate
        MASK_i(K) <= ((K+1)*SHIFT_MASK_OFFSET_c-1 downto 0 => FILL_i) & I(WORD_SIZE_c-1 downto K*SHIFT_MASK_OFFSET_c) when DIR = '1' else 
                     I(WORD_SIZE_c-K*SHIFT_MASK_OFFSET_c-1 downto 0) & (SHIFT_MASK_OFFSET_c*(K+1)-1 downto 0 => '0');
    end generate;

    COARSE_SEL_i <= VAL(SHIFT_COARSE_UPPER_c downto SHIFT_COARSE_LOWER_c); 
    FINE_SEL_i <= VAL(SHIFT_FINE_UPPER_c downto SHIFT_FINE_LOWER_c);

    -- Corse grain selection
    COARSE_i <= MASK_i(to_integer(unsigned(COARSE_SEL_i)));

    -- Fine grain shift
    SLICE_GEN : for K in 0 to SHIFT_SLICE_NUMBER_c-1 generate
        SLICE_i(K) <= COARSE_i(WORD_SIZE_c+K-1 downto K) when DIR = '1' else 
                   COARSE_i(SHIFT_MASK_SIZE_c-K-1 downto SHIFT_MASK_OFFSET_c-K);
    end generate;

    RES <= SLICE_i(to_integer(unsigned(FINE_SEL_i)));

end BEHAVIOURAL;

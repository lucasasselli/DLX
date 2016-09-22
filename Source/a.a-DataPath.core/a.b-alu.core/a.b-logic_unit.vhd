library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.globals.all;

entity LOGIC_UNIT is
    port ( 
        A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        SEL : in std_logic_vector(3 downto 0);
        RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
    );
end LOGIC_UNIT;

architecture BEHAVIOURAL of LOGIC_UNIT is

    type L_BUS_t is array(0 to 3) of std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal L_i : L_BUS_t;

begin

    L_i(0) <= not(not(A) and not(B) and (WORD_SIZE_c-1 downto 0 => SEL(0)));
    L_i(1) <= not(not(A) and B and (WORD_SIZE_c-1 downto 0 => SEL(1)));
    L_i(2) <= not(A and not(B) and (WORD_SIZE_c-1 downto 0 => SEL(2)));
    L_i(3) <= not(A and B and (WORD_SIZE_c-1 downto 0 => SEL(3)));

    RES <= not(L_i(0) and L_i(1) and L_i(2) and L_i(3));

end BEHAVIOURAL;

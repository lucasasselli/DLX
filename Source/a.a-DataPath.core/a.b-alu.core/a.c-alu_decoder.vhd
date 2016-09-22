library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.globals.all;

entity AOP_DECODER is
    port ( 
        AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
        ACTRL : out std_logic_vector(ACTRL_SIZE_c-1 downto 0)
    );
end AOP_DECODER;

architecture BEHAVIOURAL of AOP_DECODER is

begin

    ACTRL <= ACTRL_MEM(to_integer(unsigned(AOP)));

end BEHAVIOURAL;

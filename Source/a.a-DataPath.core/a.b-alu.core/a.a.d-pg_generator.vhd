library ieee; 
use ieee.std_logic_1164.all; 

entity PG_GENERATOR is
    port (
        A : in std_logic;
        B : in std_logic;
        O : out std_logic_vector(1 downto 0)
    );
end entity ;

architecture BEHAVIOURAL of PG_GENERATOR is
    alias G : std_logic is O(0);
    alias P : std_logic is O(1);
begin
    P <= A xor B;
    G <= A and B;
end architecture;

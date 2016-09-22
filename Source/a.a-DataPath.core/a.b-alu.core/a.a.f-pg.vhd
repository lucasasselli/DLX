library ieee; 
use ieee.std_logic_1164.all; 

entity PG is
    port (
        A : in std_logic_vector(1 downto 0);
        B : in std_logic_vector(1 downto 0);
        O : out std_logic_vector(1 downto 0)
    );
end entity ;

architecture BEHAVIOURAL of PG is
    -- Alias are used to keep the code clean while use the signals' names used in class
    alias G_i_k : std_logic is A(0);
    alias P_i_k : std_logic is A(1);
    alias G_kminus1_j : std_logic is B(0);
    alias P_kminus1_j : std_logic is B(1);
    alias G_i_j : std_logic is O(0);
    alias P_i_j : std_logic is O(1);

begin

    G_i_j <= G_i_k or (P_i_k and G_kminus1_j);
    P_i_j <= P_i_k and P_kminus1_j;

end architecture;

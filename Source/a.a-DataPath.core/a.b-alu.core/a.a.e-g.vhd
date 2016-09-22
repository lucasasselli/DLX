library ieee; 
use ieee.std_logic_1164.all; 

entity G is
    port (
        A : in std_logic_vector(1 downto 0);
        B : in std_logic;
        O : out std_logic
    ) ;
end entity ;

architecture BEHAVIOURAL of G is
    -- Alias are used to keep the code clean while use the signals' names used in class
    -- in std_logic_vectors index 0 means G, index 1 means P
    alias G_i_k : std_logic is A(0);
    alias P_i_k : std_logic is A(1);
    alias G_i_j : std_logic is O;
    alias G_kminus1_j : std_logic is B;

begin

    G_i_j <= G_i_k or (P_i_k and G_kminus1_j);

end architecture;

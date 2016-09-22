library ieee;
use ieee.std_logic_1164.all;

entity MUX41_GEN is
    generic (NBIT: integer);
    port (A: in std_logic_vector(NBIT-1 downto 0) ;
          B: in std_logic_vector(NBIT-1 downto 0);
          C: in std_logic_vector(NBIT-1 downto 0);
          D: in std_logic_vector(NBIT-1 downto 0);
          SEL: in std_logic_vector(1 downto 0);
          Y: out std_logic_vector(NBIT-1 downto 0));
end MUX41_GEN;

architecture BEHAVIOURAL of MUX41_GEN is
begin
    Y <= A when SEL="00" else 
         B when SEL="01" else 
         C when SEL="10" else 
         D;
end BEHAVIOURAL;

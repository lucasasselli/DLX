library ieee;
use ieee.std_logic_1164.all;

entity MUX21_GEN is
    generic (NBIT: integer);
    port (A: in std_logic_vector(NBIT-1 downto 0) ;
          B: in std_logic_vector(NBIT-1 downto 0);
          SEL: in std_logic;
          Y: out std_logic_vector(NBIT-1 downto 0));
end MUX21_GEN;

architecture BEHAVIOURAL of MUX21_GEN is
begin
    Y <= A when SEL='0' else B;
end BEHAVIOURAL;

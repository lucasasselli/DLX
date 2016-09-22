library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ZERO_GEN is
    generic (NBIT: integer);
    port (
        A: in std_logic_vector(NBIT-1 downto 0);
        ZERO : out std_logic
    );
end ZERO_GEN;

architecture BEHAVIOURAL of ZERO_GEN is
begin
    ZERO <= '1' when A = (NBIT-1 downto 0 => '0') else '0';
end BEHAVIOURAL;

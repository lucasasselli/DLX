library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity MUX_FWD is
    port (
        I: in std_logic_vector(WORD_SIZE_c-1 downto 0); -- Regular input
        S3: in std_logic_vector(WORD_SIZE_c-1 downto 0); -- S3 output
        S4: in std_logic_vector(WORD_SIZE_c-1 downto 0); -- S4 output
        FWD_EN : in std_logic; -- Forwarding enable
        S_SEL : in std_logic; -- Stage selection (0: S3, 1: S4);
        O : out std_logic_vector(WORD_SIZE_c-1 downto 0) -- Output
    );
end MUX_FWD;

architecture BEHAVIOURAL of MUX_FWD is
begin
    -- PURPOSE : Forward multiplexer
    -- TYPE : combinational
    -- INPUTS : I, S3, S4, FWD_EN, S_SEL
    -- OUTPUTS : O
    MUX_FWD_P : process(I, S3, S4, FWD_EN, S_SEL) is
    begin
        if(FWD_EN = '1') then
            -- Forward is enabled
            if(S_SEL = '0') then
                -- Forward from S3
                O <= S3;
            else
                -- Forward from S4
                O <= S4;
            end if;
        else
            -- Forward disabled
            O <= I;
        end if;
    end process;
end BEHAVIOURAL;

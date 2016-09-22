library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.globals.all;

entity IRAM is
    port (
        RESET : in std_logic;
        ADDR : in std_logic_vector(IRAM_ADDR_SIZE_c - 1 downto 0);
        RD_DATA : out std_logic_vector(WORD_SIZE_c - 1 downto 0)
    );
end IRAM;

architecture BEHAVIOURAL of IRAM is
    type TYPE_IRAM is array (0 to IRAM_SIZE_c - 1) of std_logic_vector(BYTE_SIZE_c-1 downto 0); -- The memory is byte addressable
    signal MEMORY : TYPE_IRAM;

begin

    -- PURPOSE: This process is in charge of filling the Instruction RAM with the firmware
    -- TYPE : combinational
    -- INPUTS : RESET
    -- OUTPUTS: MEMORY
    FILL_MEMORY_P: process (RESET)
        file MEMORY_FP : text;
        variable FILE_LINE : line;
        variable INDEX : integer := 0;
        variable TMP_DATA_U : std_logic_vector(BYTE_SIZE_c-1 downto 0);
    begin 
        if (RESET = '0') then

            -- Load data from file
            file_open(MEMORY_FP,"iram",READ_MODE);
            while (not endfile(MEMORY_FP)) loop
                readline(MEMORY_FP,FILE_LINE);
                hread(FILE_LINE,TMP_DATA_U);
                MEMORY(INDEX) <= TMP_DATA_U; 
                INDEX := INDEX + 1;
            end loop;

            -- Clear the rest of the memory
            while(INDEX < IRAM_SIZE_c) loop
                MEMORY(INDEX) <= (others => '0');
                INDEX := INDEX + 1;
            end loop;

        end if;
    end process FILL_MEMORY_P;

    RD_DATA <= MEMORY(to_integer(unsigned(ADDR)) + 0) & 
                MEMORY(to_integer(unsigned(ADDR)) + 1) &
                MEMORY(to_integer(unsigned(ADDR)) + 2) &
                MEMORY(to_integer(unsigned(ADDR)) + 3);

end BEHAVIOURAL;

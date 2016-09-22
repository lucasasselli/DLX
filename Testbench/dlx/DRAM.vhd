library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.globals.all;

entity DRAM is
    port(CLK : in std_logic;
         RESET : in std_logic;
         WR_DATA : in std_logic_vector(WORD_SIZE_c-1 downto 0);
         RD_DATA : out std_logic_vector(WORD_SIZE_c-1 downto 0);
         WR_EN : in std_logic; -- Write enable
         RD_EN : in std_logic; -- Read enable
         ADDR : in std_logic_vector(DRAM_ADDR_SIZE_c-1 downto 0));
end DRAM;

architecture BEHAVIORAL of DRAM is
    subtype ADDR_TYPE is natural range 0 to DRAM_SIZE_c-1;
    type DRAM_TYPE is array(ADDR_TYPE) of std_logic_vector(BYTE_SIZE_c-1 downto 0);
    signal MEMORY : DRAM_TYPE;

begin
    -- PURPOSE: manage firmware loading and main operations
    -- TYPE : sequential
    -- INPUTS : CLK, RESET
    -- OUTPUTS: RD_DATA, MEMORY
    DRAM_P: process (CLK, RESET)
        file MEMORY_FP : text;
        variable FILE_LINE : line;
        variable INDEX : integer := 0;
        variable TMP_DATA_U : std_logic_vector(BYTE_SIZE_c-1 downto 0);
    begin 
        if (RESET = '0') then
            -- Load data from file
            file_open(MEMORY_FP,"dram",READ_MODE);
            while (not endfile(MEMORY_FP)) loop
                readline(MEMORY_FP,FILE_LINE);
                hread(FILE_LINE,TMP_DATA_U);
                MEMORY(INDEX) <= TMP_DATA_U; 
                INDEX := INDEX + 1;
            end loop;

            -- Clear the rest of the memory
            while(INDEX < DRAM_SIZE_c) loop
                MEMORY(INDEX) <= (others => '0');
                INDEX := INDEX + 1;
            end loop;

        elsif CLK'event and CLK='0' then -- Falling edge
            if(WR_EN = '1') then
                MEMORY(to_integer(unsigned(ADDR)) + 0) <= WR_DATA(WORD_SIZE_c-BYTE_SIZE_c*0-1 downto BYTE_SIZE_c*3); 
                MEMORY(to_integer(unsigned(ADDR)) + 1) <= WR_DATA(WORD_SIZE_c-BYTE_SIZE_c*1-1 downto BYTE_SIZE_c*2); 
                MEMORY(to_integer(unsigned(ADDR)) + 2) <= WR_DATA(WORD_SIZE_c-BYTE_SIZE_c*2-1 downto BYTE_SIZE_c*1); 
                MEMORY(to_integer(unsigned(ADDR)) + 3) <= WR_DATA(WORD_SIZE_c-BYTE_SIZE_c*3-1 downto BYTE_SIZE_c*0); 
            end if;

            if(RD_EN = '1') then
                RD_DATA <= MEMORY(to_integer(unsigned(ADDR)) + 0) & 
                            MEMORY(to_integer(unsigned(ADDR)) + 1) &
                            MEMORY(to_integer(unsigned(ADDR)) + 2) &
                            MEMORY(to_integer(unsigned(ADDR)) + 3);
            end if;
        end if;
    end process DRAM_P;
end BEHAVIORAL;

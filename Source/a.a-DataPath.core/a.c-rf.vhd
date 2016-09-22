library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.globals.all;

entity RF is
    port(CLK : in std_logic;
         RESET : in std_logic;
         RD_A : out std_logic_vector(WORD_SIZE_c-1 downto 0); -- Data ports
         RD_B : out std_logic_vector(WORD_SIZE_c-1 downto 0);
         WR_A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
         WR_B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
         WR_A_EN : in std_logic; -- Write enable
         WR_B_EN : in std_logic; 
         RD_A_EN : in std_logic; -- Read enable
         RD_B_EN : in std_logic; 
         RD_A_ADDR : in std_logic_vector(RF_ADDR_SIZE_c-1 downto 0); -- Address ports
         RD_B_ADDR : in std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);
         WR_A_ADDR : in std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);
         WR_B_ADDR : in std_logic_vector(RF_ADDR_SIZE_c-1 downto 0)
     );
end RF;

architecture BEHAVIORAL of RF is
    subtype ADDR_TYPE is natural range 0 to RF_SIZE_c-1;
    type RF_TYPE is array(ADDR_TYPE) of std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal REGISTERS : RF_TYPE;

begin
    P_RF : process (CLK)
    begin
        if CLK'event and CLK='0' then -- Falling Edge
            if RESET='0' then -- Active low reset 
                REGISTERS <= (others => (others => '0')); -- Clear registers content
                RD_A <= (others => '0'); -- Clear the value on read ports
                RD_B <= (others => '0');
            else
                if(WR_A_EN='1') then
                    REGISTERS(to_integer(unsigned(WR_A_ADDR))) <= WR_A; -- Write from port A
                end if;

                if(WR_B_EN='1') then
                    REGISTERS(to_integer(unsigned(WR_B_ADDR))) <= WR_B; -- Write from port B
                end if;

                if(RD_A_EN='1') then
                    if(RD_A_ADDR = WR_A_ADDR and WR_A_EN='1') then
                        RD_A <= WR_A; -- Write port A to read port A
                    elsif(RD_A_ADDR = WR_B_ADDR and WR_B_EN='1') then
                        RD_A <= WR_B; -- Write port B to read port A
                    else
                        RD_A <= REGISTERS(to_integer(unsigned(RD_A_ADDR))); -- Read on port A
                    end if;
                end if;

                if(RD_B_EN='1') then
                    if(RD_B_ADDR = WR_A_ADDR and WR_A_EN='1') then
                        RD_B <= WR_A; -- Write port A to read port B
                    elsif(RD_B_ADDR = WR_B_ADDR and WR_B_EN='1') then
                        RD_B <= WR_B; -- Write port B to read port B
                    else
                        RD_B <= REGISTERS(to_integer(unsigned(RD_B_ADDR))); -- Read on port B
                    end if;
                end if;
            end if;
        end if;
    end process;
end BEHAVIORAL;

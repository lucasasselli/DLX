library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity TB_DLX is
    end TB_DLX;

architecture TEST of TB_DLX is

    -- DUT
    component DLX is
        port (
            CLK : in std_logic;
            RESET : in std_logic; -- Active Low
            DRAM_WR_DATA : out std_logic_vector(WORD_SIZE_c-1 downto 0);
            DRAM_RD_DATA : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            DRAM_WR_EN : out std_logic; 
            DRAM_RD_EN : out std_logic; 
            DRAM_ADDR : out std_logic_vector(DRAM_ADDR_SIZE_c-1 downto 0);
            IRAM_RD_DATA : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            IRAM_ADDR : out std_logic_vector(IRAM_ADDR_SIZE_c-1 downto 0)
        ); 
    end component;

    -- Data RAM 
    component DRAM is
        port(CLK : in std_logic;
             RESET : in std_logic;
             WR_DATA : in std_logic_vector(WORD_SIZE_c-1 downto 0);
             RD_DATA : out std_logic_vector(WORD_SIZE_c-1 downto 0);
             WR_EN : in std_logic; -- Write enable
             RD_EN : in std_logic; -- Read enable
             ADDR : in std_logic_vector(DRAM_ADDR_SIZE_c-1 downto 0));
    end component;

    -- Instruction RAM
    component IRAM is
        port (
            RESET : in std_logic;
            ADDR : in std_logic_vector(IRAM_ADDR_SIZE_c - 1 downto 0);
            RD_DATA : out std_logic_vector(WORD_SIZE_c - 1 downto 0)
        );
    end component;

    signal CLK: std_logic := '0';
    signal RESET: std_logic := '1';

    signal DRAM_WR_DATA_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal DRAM_RD_DATA_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal DRAM_WR_EN_i : std_logic; 
    signal DRAM_RD_EN_i : std_logic; 
    signal DRAM_ADDR_i : std_logic_vector(DRAM_ADDR_SIZE_c-1 downto 0);
    signal IRAM_RD_DATA_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal IRAM_ADDR_i : std_logic_vector(IRAM_ADDR_SIZE_c-1 downto 0);
begin


    DLX_I : DLX
    port map (
        CLK => CLK,
        RESET => RESET,
        DRAM_WR_DATA => DRAM_WR_DATA_i,
        DRAM_RD_DATA => DRAM_RD_DATA_i,
        DRAM_WR_EN => DRAM_WR_EN_i,
        DRAM_RD_EN => DRAM_RD_EN_i,
        DRAM_ADDR => DRAM_ADDR_i,
        IRAM_RD_DATA => IRAM_RD_DATA_i,
        IRAM_ADDR => IRAM_ADDR_i
    );

    DRAM_I : DRAM
    port map (
        CLK => CLK,
        RESET => RESET,
        WR_DATA => DRAM_WR_DATA_i,
        RD_DATA => DRAM_RD_DATA_i,
        WR_EN => DRAM_WR_EN_i,
        RD_EN => DRAM_RD_EN_i,
        ADDR => DRAM_ADDR_i);


    IRAM_0 : IRAM
    port map (
        RESET => RESET,
        ADDR => IRAM_ADDR_i,
        RD_DATA => IRAM_RD_DATA_i
    );


    CLK_P : process(CLK)
    begin
        CLK <= not(CLK) after 0.5 ns; 
    end process;

    RESET <= '0', '1' after 6 ns;

end TEST;

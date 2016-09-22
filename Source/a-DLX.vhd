library ieee;
use ieee.std_logic_1164.all;
use work.globals.all;

entity DLX is
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
end DLX;

architecture RTL of DLX is

    --------------------------------------------------------------------
    -- Components declaration
    --------------------------------------------------------------------

    -- Datapath
    component DLX_DP is
        port(
            CLK : in std_logic;
            RESET : in std_logic;
            CTRL : in std_logic_vector(CTRL_SIZE_c-1 downto 0);
            AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
            STAT : out std_logic_vector(STAT_SIZE_c-1 downto 0);
            FWD : in std_logic_vector(FWD_SIZE_c-1 downto 0);
            FETCH : in std_logic;
            IR : in std_logic_vector(WORD_SIZE_c-1 downto 0); 
            PC_in : out std_logic_vector(WORD_SIZE_c-1 downto 0); -- to PC input
            PC_out : in std_logic_vector(WORD_SIZE_c-1 downto 0); -- from PC output
            DRAM_WR_DATA : out std_logic_vector(WORD_SIZE_c-1 downto 0); -- to DRAM input
            DRAM_RD_DATA : in std_logic_vector(WORD_SIZE_c-1 downto 0); -- from DRAM output
            DRAM_ADDR : out std_logic_vector(DRAM_ADDR_SIZE_c-1 downto 0) -- to DRAM address
        );
    end component;

    -- Control Unit
    component DLX_CU is
        port (
            CLK : in std_logic; 
            RESET : in std_logic;
            IR : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            CTRL : out std_logic_vector(CTRL_SIZE_c-1 downto 0);
            AOP : out std_logic_vector(AOP_SIZE_c-1 downto 0);
            STAT : in std_logic_vector(STAT_SIZE_c-1 downto 0);
            FWD : out std_logic_vector(FWD_SIZE_c-1 downto 0);
            FETCH : out std_logic
        );
    end component;


    ----------------------------------------------------------------
    -- Signals declaration
    ----------------------------------------------------------------

    -- Instruction Register (IR) and Program Counter (PC) declaration
    signal IR_in_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal IR_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal PC_in_i: std_logic_vector(WORD_SIZE_c - 1 downto 0);
    signal PC_out_i : std_logic_vector(WORD_SIZE_c - 1 downto 0);

    -- Instruction RAM bus signals
    signal IRAM_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0); 

    -- Control Unit Bus signals
    signal CTRL_i : std_logic_vector(CTRL_SIZE_c-1 downto 0);
    signal AOP_i : std_logic_vector(AOP_SIZE_c-1 downto 0); 
    signal FWD_i : std_logic_vector(FWD_SIZE_c-1 downto 0);
    signal FETCH_i : std_logic;

    -- Datapath bus signals
    signal STAT_i : std_logic_vector(STAT_SIZE_c-1 downto 0);

begin 

    -- Stall MUX
    IR_in_i <= IRAM_out_i;

    -- PURPOSE: Instruction register
    -- TYPE : sequential
    -- INPUTS : CLK, RESET, IRAM_out_i, FETCH_i
    -- OUTPUTS: IR_in_i
    IR_P: process (CLK, RESET)
    begin -- process IR_P
        if RESET = '0' then -- asynchronous reset (active low)
            IR_out_i <= (others => '0');
        elsif CLK'event and CLK = '1' then -- rising clock edge
            if (FETCH_i = '1') then
                IR_out_i <= IRAM_out_i;
            end if;
        end if;
    end process IR_P;

    -- PURPOSE: Program counter
    -- TYPE : sequential
    -- INPUTS : CLK, RESET, PC_in_i, FETCH_i
    -- OUTPUTS: PC_out_i
    PC_P: process (CLK, RESET)
    begin -- process PC_P
        if RESET = '0' then -- asynchronous reset (active low)
            PC_out_i <= (others => '0');
        elsif CLK'event and CLK = '1' then -- rising clock edge
            if (FETCH_i = '1') then
                PC_out_i <= PC_in_i;
            end if;
        end if;
    end process PC_P;

    -- Control unit instantiation
    DLX_CU_I : DLX_CU
    port map (
        CLK => CLK,
        RESET => RESET,
        IR => IRAM_out_i, 
        CTRL => CTRL_i,
        AOP => AOP_i,
        STAT => STAT_i,
        FWD => FWD_i,
        FETCH => FETCH_i
    );

    -- Datapath instantiation
    DLX_DP_I : DLX_DP
    port map (
        CLK => CLK,
        RESET => RESET,
        CTRL => CTRL_i,
        AOP => AOP_i,
        STAT => STAT_i,
        FWD => FWD_i,
        FETCH => FETCH_i,
        IR => IR_out_i,
        PC_in => PC_in_i,
        PC_out => PC_out_i,
        DRAM_WR_DATA => DRAM_WR_DATA,
        DRAM_RD_DATA => DRAM_RD_DATA,
        DRAM_ADDR => DRAM_ADDR
    );

    DRAM_WR_EN <= CTRL_i(CTRL_S4_DRAM_WR_EN);
    DRAM_RD_EN <= CTRL_i(CTRL_S4_DRAM_RD_EN);

    IRAM_ADDR <= PC_out_i(IRAM_ADDR_SIZE_c-1 downto 0);
    IRAM_out_i <= IRAM_RD_DATA;

end RTL;

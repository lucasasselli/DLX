library ieee; 
use ieee.std_logic_1164.all; 
use work.globals.all;

entity DLX_DP is
    port(
        CLK : in std_logic;
        RESET : in std_logic;

        CTRL : in std_logic_vector(CTRL_SIZE_c-1 downto 0);
        AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
        FWD : in std_logic_vector(FWD_SIZE_c-1 downto 0); 
        FETCH : in std_logic;
        STAT : out std_logic_vector(STAT_SIZE_c-1 downto 0);

        IR : in std_logic_vector(WORD_SIZE_c-1 downto 0); 
        PC_in : out std_logic_vector(WORD_SIZE_c-1 downto 0); -- to PC input
        PC_out : in std_logic_vector(WORD_SIZE_c-1 downto 0); -- from PC output
        DRAM_WR_DATA : out std_logic_vector(WORD_SIZE_c-1 downto 0); -- to DRAM input
        DRAM_RD_DATA : in std_logic_vector(WORD_SIZE_c-1 downto 0); -- from DRAM output
        DRAM_ADDR : out std_logic_vector(DRAM_ADDR_SIZE_c-1 downto 0) -- to DRAM address
    );
end DLX_DP;

architecture RTL of DLX_DP is

    --------------------------------------------------
    -- Components declaration
    --------------------------------------------------

    -- Generic register
    component GPR_GEN is
        generic(NBIT: integer);
        port (D: in std_logic_vector(NBIT-1 downto 0);
              CLK: in std_logic;
              RESET: in std_logic;
              EN : in std_logic;
              Q: out std_logic_vector(NBIT-1 downto 0));
    end component;

    -- Generic multiplexer 2to1
    component MUX21_GEN is
        generic (NBIT: integer);
        port (A: in std_logic_vector(NBIT-1 downto 0) ;
              B: in std_logic_vector(NBIT-1 downto 0);
              SEL: in std_logic;
              Y: out std_logic_vector(NBIT-1 downto 0));
    end component;

    -- Forward multiplexer
    component MUX_FWD is
        port (
            I: in std_logic_vector(WORD_SIZE_c-1 downto 0); -- Regular input
            S3: in std_logic_vector(WORD_SIZE_c-1 downto 0); -- S3 output
            S4: in std_logic_vector(WORD_SIZE_c-1 downto 0); -- S4 output
            FWD_EN : in std_logic; -- Forwarding enable
            S_SEL : in std_logic; -- Stage selection (0: S2, 1: S3);
            O : out std_logic_vector(WORD_SIZE_c-1 downto 0) -- Output
        );
    end component;

    -- Generic RCA
    component RCA_GEN is 
        generic(NBIT: integer);
        port (A: in std_logic_vector(NBIT-1 downto 0);
              B: in std_logic_vector(NBIT-1 downto 0);
              C_in: in std_logic;
              S: out std_logic_vector(NBIT-1 downto 0);
              C_out: out std_logic);
    end component;

    component P4_ADDER is 
        port (A: in std_logic_vector(WORD_SIZE_c-1 downto 0);
              B: in std_logic_vector(WORD_SIZE_c-1 downto 0);
              C_in: in std_logic;
              S: out std_logic_vector(WORD_SIZE_c-1 downto 0);
              C_out: out std_logic);
    end component;

    -- Register file
    component RF is
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
    end component;

    -- ALU
    component ALU is
        port ( AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
               A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
               B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
               RES : out std_logic_vector(WORD_SIZE_c-1 downto 0));
    end component;

    -- Is zero comparator
    component ZERO_GEN is
        generic (NBIT: integer);
        port (
            A: in std_logic_vector(NBIT-1 downto 0);
            ZERO : out std_logic
        );
    end component;


    --------------------------------------------------
    -- Signals declaration
    --------------------------------------------------

    -- S1 internal signals
    -- Empty

    -- S2 internal signals
    signal RF_A_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RF_B_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RF_ADDR_A_i : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);
    signal RF_ADDR_B_i : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);
    signal A_in_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal A_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal B_in_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal B_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal IMM16_in_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal IMM16_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal JUMP_OFFSET_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal BRANCH_OFFSET_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal OFFSET_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal BRANCH_TARGET_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal IS_ZERO_i : std_logic;
    signal BRANCH_i : std_logic;


    -- S3 internal Signals
    signal RES_in_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RES_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal ALU_A_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal ALU_B_i : std_logic_vector(WORD_SIZE_c-1 downto 0);

    -- S4 internal Signals
    signal WBD_in_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal WBD_out_i : std_logic_vector(WORD_SIZE_c-1 downto 0);

    -- S5 internal Signals
    -- Empty

    -- Pipeline Signals
    signal NPC_D0_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal NPC_D1_i : std_logic_vector(WORD_SIZE_c-1 downto 0);

    signal WBA_D0_i : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0); 
    signal WBA_D1_i : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);
    signal WBA_D2_i : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);
    signal WBA_D3_i : std_logic_vector(RF_ADDR_SIZE_c-1 downto 0);

    signal B_D0_i : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal B_D1_i : std_logic_vector(WORD_SIZE_c-1 downto 0);

begin

    -------------------------------------------------- 
    -- S1
    -------------------------------------------------- 

    PC_ADDER : P4_ADDER
    port map (
        A => PC_out,
        B => PC_inCR_c,
        C_in => '0',
        S => NPC_D0_i,
        C_out => open);

    -------------------------------------------------- 
    -- S2
    -------------------------------------------------- 

    RF_ADDR_A_i <= IR(FIELD_RA_UPPER_c downto FIELD_RA_LOWER_c);
    RF_ADDR_B_i <= IR(FIELD_RB_UPPER_c downto FIELD_RB_LOWER_c);

    RF_I : RF
    port map (
        CLK => CLK,
        RESET => RESET,
        RD_A => RF_A_i,
        RD_B => RF_B_i,
        WR_A => WBD_out_i,
        WR_B => NPC_D1_i,
        WR_A_EN => CTRL(CTRL_S5_RF_WR_EN),
        WR_B_EN => CTRL(CTRL_S2_LINK_EN),
        RD_A_EN => CTRL(CTRL_S2_RF_A_EN),
        RD_B_EN => CTRL(CTRL_S2_RF_B_EN),
        RD_A_ADDR => RF_ADDR_A_i,
        RD_B_ADDR => RF_ADDR_B_i,
        WR_A_ADDR => WBA_D3_i, 
        WR_B_ADDR => LINK_ADDR_c 
    );

    -- Forwarding

    MUX_FWD_A : MUX_FWD
    port map (
        I => RF_A_i,
        S3 => RES_in_i,
        S4 => WBD_in_i,
        FWD_EN => FWD(FWD_A_EN),
        S_SEL => FWD(FWD_A_SEL),
        O => A_in_i
    );

    MUX_FWD_B : MUX_FWD
    port map (
        I => RF_B_i,
        S3 => RES_in_i,
        S4 => WBD_in_i,
        FWD_EN => FWD(FWD_B_EN),
        S_SEL => FWD(FWD_B_SEL),
        O => B_in_i
    );

    A : GPR_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        D => A_in_i,
        CLK => CLK,
        RESET => RESET,
        EN => CTRL(CTRL_S2_EN),
        Q => A_out_i );

    B : GPR_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        D => B_in_i,
        CLK => CLK,
        RESET => RESET,
        EN => CTRL(CTRL_S2_EN),
        Q => B_out_i );

    -- Jump/Branch execution

    -- Compare A to zero
    ZERO_GEN_0 : ZERO_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        A => A_in_i,
        ZERO => IS_ZERO_i
    );

    -- Fix target values
    JUMP_OFFSET_i <= (WORD_SIZE_c-1 downto IMM26_SIZE_c => IR(FIELD_IMM26_UPPER_c)) & IR(FIELD_IMM26_UPPER_c downto FIELD_IMM26_LOWER_c); 
    BRANCH_OFFSET_i <= (WORD_SIZE_c-1 downto IMM16_SIZE_c => IR(FIELD_IMM16_UPPER_c)) & IR(FIELD_IMM16_UPPER_c downto FIELD_IMM16_LOWER_c); 

    MUX_TARGET : MUX21_GEN
    generic map (
        NBIT => WORD_SIZE_c)
    port map (
        A => BRANCH_OFFSET_i,
        B => JUMP_OFFSET_i,
        SEL => CTRL(CTRL_S2_JUMP_EN), 
        Y => OFFSET_i);

    BRANCH_ADDER : P4_ADDER
    port map (
        A => NPC_D1_i,
        B => OFFSET_i,
        C_in => '0',
        S => BRANCH_TARGET_i,
        C_out => open);

    BRANCH_i <= CTRL(CTRL_S2_JUMP_EN) or (CTRL(CTRL_S2_BRANCH_EN) and (CTRL(CTRL_S2_BRANCH_COND) xnor IS_ZERO_i));
    STAT(STAT_BRANCH_FLAG) <= BRANCH_i;

    MUX_BRANCH : MUX21_GEN
    generic map (
        NBIT => WORD_SIZE_c)
    port map (
        A => NPC_D0_i,
        B => BRANCH_TARGET_i,
        SEL => BRANCH_i, 
        Y => PC_in );

    IMM16_in_i <= (WORD_SIZE_c-1 downto IMM16_SIZE_c => IR(FIELD_IMM16_UPPER_c)) & IR(FIELD_IMM16_UPPER_c downto FIELD_IMM16_LOWER_c);

    IMM16 : GPR_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        D => IMM16_in_i,
        CLK => CLK,
        RESET => RESET,
        EN => CTRL(CTRL_S2_EN),
        Q => IMM16_out_i );

    MUX_WBA : MUX21_GEN
    generic map (
        NBIT => RF_ADDR_SIZE_c)
    port map (
        A => IR(WORD_SIZE_c-12 downto WORD_SIZE_c-16), -- I-type
        B => IR(WORD_SIZE_c-17 downto WORD_SIZE_c-21), -- R-type
        SEL => CTRL(CTRL_S2_WBA_SEL),
        Y => WBA_D0_i );

    -------------------------------------------------- 
    -- S3
    -------------------------------------------------- 

    ALU_A_i <= A_out_i;

    MUX_B : MUX21_GEN
    generic map (
        NBIT => WORD_SIZE_c)
    port map (
        A => IMM16_out_i,
        B => B_out_i,
        SEL => CTRL(CTRL_S3_B_SEL),
        Y => ALU_B_i);

    ALU_I : ALU
    port map (
        AOP => AOP,
        A => ALU_A_i,
        B => ALU_B_i,
        RES => RES_in_i);

    RES : GPR_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        D => RES_in_i,
        CLK => CLK,
        RESET => RESET,
        EN => CTRL(CTRL_S3_EN),
        Q => RES_out_i);

    B_D0_i <= B_out_i;

    --------------------------------------------------
    -- S4
    --------------------------------------------------

    MUX_WB : MUX21_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        A => RES_out_i,
        B => DRAM_RD_DATA,
        SEL => CTRL(CTRL_S4_WB_SEL),
        Y => WBD_in_i);

    WBD : GPR_GEN
    generic map (
        NBIT => WORD_SIZE_c )
    port map (
        D => WBD_in_i,
        CLK => CLK,
        RESET => RESET,
        EN => CTRL(CTRL_S4_EN),
        Q => WBD_out_i );

    DRAM_WR_DATA <= B_D1_i;
    DRAM_ADDR <= RES_out_i(DRAM_ADDR_SIZE_c-1 downto 0);

    --------------------------------------------------
    -- S5
    --------------------------------------------------

    -- NOTE: S5 only operates with RF, already defined for S2

    --------------------------------------------------
    -- Pipelines
    --------------------------------------------------

    -- NOTE: This process is only for delay pipelines, to avoid long chains of components. Stage registers are defined using GPR.

    -- PURPOSE : run internal registers pipelines
    -- TYPE : sequential
    -- INPUTS : CLK, RESET, NPC_D0_i, WBA_D0_i, B_D0_i
    -- OUTPUTS : WBA_D3_i, NPC_D1_i, B_D1_i
    P_PIPELINE : process(CLK,RESET)
    begin
        if RESET='0' then

            NPC_D1_i <= (others => '0');

            WBA_D1_i <= (others => '0');
            WBA_D2_i <= (others => '0');
            WBA_D3_i <= (others => '0');

            B_D1_i <= (others => '0');

        elsif CLK'event and CLK='1' then -- positive edge triggered

            -- S1
            if(FETCH = '1') then
                NPC_D1_i <= NPC_D0_i;
            end if;

            -- S2
            if(CTRL(CTRL_S2_EN) = '1') then
                WBA_D1_i <= WBA_D0_i;
            end if;

            -- S3
            if(CTRL(CTRL_S3_EN) = '1') then
                B_D1_i <= B_D0_i;
                WBA_D2_i <= WBA_D1_i;
            end if;

            -- S4
            if(CTRL(CTRL_S4_EN) = '1') then
                WBA_D3_i <= WBA_D2_i;
            end if;

        end if;
    end process;


    -------------------------------------------------- 
    -- Hazard detection
    -------------------------------------------------- 

    -- Port A
    STAT(STAT_S3_A_MATCH) <= '1' when (RF_ADDR_A_i = WBA_D1_i and CTRL(CTRL_S2_RF_A_EN) = '1') else '0';
    STAT(STAT_S4_A_MATCH) <= '1' when (RF_ADDR_A_i = WBA_D2_i and CTRL(CTRL_S2_RF_A_EN) = '1') else '0';

    -- Port B
    STAT(STAT_S3_B_MATCH) <= '1' when (RF_ADDR_B_i = WBA_D1_i and CTRL(CTRL_S2_RF_B_EN) = '1') else '0';
    STAT(STAT_S4_B_MATCH) <= '1' when (RF_ADDR_B_i = WBA_D2_i and CTRL(CTRL_S2_RF_B_EN) = '1') else '0';

end RTL;

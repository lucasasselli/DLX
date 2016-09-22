library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.globals.all;

entity DLX_CU is
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
end DLX_CU;

architecture BEHAVIOURAL of DLX_CU is

    -------------------------------------------------- 
    -- Constants declaration
    -------------------------------------------------- 

    constant CTRL_REG_S1_SIZE_c : integer := CTRL_SIZE_c;
    constant CTRL_REG_S2_SIZE_c : integer := CTRL_S2_SIZE_c + CTRL_S3_SIZE_c + CTRL_S4_SIZE_c + CTRL_S5_SIZE_c;
    constant CTRL_REG_S3_SIZE_c : integer := CTRL_S3_SIZE_c + CTRL_S4_SIZE_c + CTRL_S5_SIZE_c;
    constant CTRL_REG_S4_SIZE_c : integer := CTRL_S4_SIZE_c + CTRL_S5_SIZE_c;
    constant CTRL_REG_S5_SIZE_c : integer := CTRL_S5_SIZE_c;

    -------------------------------------------------- 
    -- Signals declaration
    -------------------------------------------------- 

    signal IR_OPC : std_logic_vector(OPC_SIZE_c-1 downto 0); -- opcode part of IR
    signal IR_FUNC : std_logic_vector(FUNC_SIZE_c-1 downto 0); -- func part of IR

    signal CTRL_REG_S1 : std_logic_vector(CTRL_REG_S1_SIZE_c-1 downto 0);
    signal CTRL_REG_S2 : std_logic_vector(CTRL_REG_S2_SIZE_c-1 downto 0);
    signal CTRL_REG_S3 : std_logic_vector(CTRL_REG_S3_SIZE_c-1 downto 0);
    signal CTRL_REG_S4 : std_logic_vector(CTRL_REG_S4_SIZE_c-1 downto 0);
    signal CTRL_REG_S5 : std_logic_vector(CTRL_REG_S5_SIZE_c-1 downto 0);

    signal AOP_REG_S1 : std_logic_vector(AOP_SIZE_c-1 downto 0) := AOP_NOP;
    signal AOP_REG_S2 : std_logic_vector(AOP_SIZE_c-1 downto 0) := AOP_NOP;
    signal AOP_REG_S3 : std_logic_vector(AOP_SIZE_c-1 downto 0) := AOP_NOP;

    signal FLUSH : std_logic;
    signal STALL : std_logic;

begin

    IR_OPC <= IR(WORD_SIZE_c-1 downto WORD_SIZE_c-OPC_SIZE_c);
    IR_FUNC <= IR(FUNC_SIZE_c-1 downto 0);

    -- PURPOSE : ALU opcode generation
    -- TYPE : combinational
    -- INPUTS : IR_OPC, IR_FUNC
    -- OUTPUTS : AOP_REG_S1
    AOP_P : process (IR_OPC, IR_FUNC)
    begin
        case IR_OPC is
            -- R type
            when OPC_R =>
                case IR_FUNC is
                    when FUNC_SLL => AOP_REG_S1 <= AOP_SLL; -- sll 
                    when FUNC_SRL => AOP_REG_S1 <= AOP_SRL; -- srl
                    when FUNC_SRA => AOP_REG_S1 <= AOP_SRA; -- sra
                    when FUNC_ADD => AOP_REG_S1 <= AOP_ADD; -- add
                    when FUNC_SUB => AOP_REG_S1 <= AOP_SUB; -- sub
                    when FUNC_AND => AOP_REG_S1 <= AOP_AND; -- and
                    when FUNC_OR => AOP_REG_S1 <= AOP_OR; -- or
                    when FUNC_XOR => AOP_REG_S1 <= AOP_XOR; -- xor
                    when FUNC_SEQ => AOP_REG_S1 <= AOP_SEQ; -- seq
                    when FUNC_SNE => AOP_REG_S1 <= AOP_SNE; -- sne
                    when FUNC_SLT => AOP_REG_S1 <= AOP_SLT; -- slt
                    when FUNC_SGT => AOP_REG_S1 <= AOP_SGT; -- sgt
                    when FUNC_SLE => AOP_REG_S1 <= AOP_SLE; -- sle
                    when FUNC_SGE => AOP_REG_S1 <= AOP_SGE; -- sge
                    when FUNC_SLTU => AOP_REG_S1 <= AOP_SLTU; -- sltu
                    when FUNC_SGTU => AOP_REG_S1 <= AOP_SGTU; -- sgtu
                    when FUNC_SLEU => AOP_REG_S1 <= AOP_SLEU; -- sleu
                    when FUNC_SGEU => AOP_REG_S1 <= AOP_SGEU; -- sgeu
                    when others => AOP_REG_S1 <= AOP_NOP;
                end case;
            -- I and J types
            when OPC_ADDI => AOP_REG_S1 <= AOP_ADD; -- addi
            when OPC_SUBI => AOP_REG_S1 <= AOP_SUB; -- subi
            when OPC_ANDI => AOP_REG_S1 <= AOP_AND; -- andi
            when OPC_ORI => AOP_REG_S1 <= AOP_OR; -- ori
            when OPC_XORI => AOP_REG_S1 <= AOP_XOR; -- xori
            when OPC_SEQI => AOP_REG_S1 <= AOP_SEQ; -- seqi
            when OPC_SNEI => AOP_REG_S1 <= AOP_SNE; -- snei
            when OPC_SLTI => AOP_REG_S1 <= AOP_SLT; -- slti
            when OPC_SGTI => AOP_REG_S1 <= AOP_SGT; -- sgti
            when OPC_SLEI => AOP_REG_S1 <= AOP_SLE; -- slei
            when OPC_SGEI => AOP_REG_S1 <= AOP_SGE; -- sgei
            when OPC_LW => AOP_REG_S1 <= AOP_ADD; -- lw
            when OPC_SW => AOP_REG_S1 <= AOP_ADD; -- sw
            when OPC_SLTUI => AOP_REG_S1 <= AOP_SLTU; -- sltui
            when OPC_SGTUI => AOP_REG_S1 <= AOP_SGTU; -- sgtui
            when OPC_SLEUI => AOP_REG_S1 <= AOP_SLEU; -- sleui
            when OPC_SGEUI => AOP_REG_S1 <= AOP_SGEU; -- sgeui
            when others => AOP_REG_S1 <= AOP_NOP;
        end case;
    end process AOP_P;

    CTRL_REG_S1 <= CTRL_MEM(to_integer(unsigned(IR_OPC)));
    FLUSH <= STAT(STAT_BRANCH_FLAG);

    -- PURPOSE : control signals pipeline
    -- TYPE : sequential
    -- INPUTS : CLK, RESET, CTRL_DX, AOP_DX
    -- OUTPUTS : CTRL_DX, AOP_DX
    CTRL_P: process (CLK, RESET, STAT)
    begin
        if RESET = '0' then 
            CTRL_REG_S2 <= (others => '0');
            CTRL_REG_S3 <= (others => '0');
            CTRL_REG_S4 <= (others => '0');
            CTRL_REG_S5 <= (others => '0');

            AOP_REG_S2 <= AOP_NOP;
            AOP_REG_S3 <= AOP_NOP;

        elsif CLK'event and CLK = '1' then
            -- Control word pipeline
            CTRL_REG_S5 <= CTRL_REG_S4(CTRL_REG_S5_SIZE_c-1 downto 0);
            CTRL_REG_S4 <= CTRL_REG_S3(CTRL_REG_S4_SIZE_c-1 downto 0);

            if(FLUSH = '1') then
                -- Flush content of S1 
                CTRL_REG_S3 <= CTRL_REG_S2(CTRL_REG_S3_SIZE_c-1 downto 0);
                CTRL_REG_S2 <= (others => '0');

                AOP_REG_S3 <= AOP_REG_S2;
                AOP_REG_S2 <= AOP_NOP;
            elsif(STALL = '1') then
                -- Stall content of S1 
                CTRL_REG_S2 <= CTRL_REG_S2;
                CTRL_REG_S3 <= (others => '0');

                AOP_REG_S3 <= AOP_NOP;
                AOP_REG_S2 <= AOP_REG_S2;
            else
                -- Regular operation
                CTRL_REG_S3 <= CTRL_REG_S2(CTRL_REG_S3_SIZE_c-1 downto 0);
                CTRL_REG_S2 <= CTRL_REG_S1(CTRL_REG_S2_SIZE_c-1 downto 0);

                AOP_REG_S3 <= AOP_REG_S2;
                AOP_REG_S2 <= AOP_REG_S1;
            end if;


        end if;
    end process CTRL_P;

    -- NOTE: S1 CTRL not used
    -- CTRL(CTRL_S1_SIZE_c-1 downto CTRL_S2_SIZE_c) <= CTRL_REG_S1(CTRL_S1_SIZE_c-1 downto CTRL_S2_SIZE_c);
    CTRL(CTRL_REG_S2_SIZE_c-1 downto CTRL_REG_S3_SIZE_c) <= CTRL_REG_S2(CTRL_REG_S2_SIZE_c-1 downto CTRL_REG_S3_SIZE_c);
    CTRL(CTRL_REG_S3_SIZE_c-1 downto CTRL_REG_S4_SIZE_c) <= CTRL_REG_S3(CTRL_REG_S3_SIZE_c-1 downto CTRL_REG_S4_SIZE_c);
    CTRL(CTRL_REG_S4_SIZE_c-1 downto CTRL_REG_S5_SIZE_c) <= CTRL_REG_S4(CTRL_REG_S4_SIZE_c-1 downto CTRL_REG_S5_SIZE_c);
    CTRL(CTRL_REG_S5_SIZE_c-1 downto 0) <= CTRL_REG_S5(CTRL_REG_S5_SIZE_c-1 downto 0);

    AOP <= AOP_REG_S3;

    -------------------------------------------------- 
    -- NOTE: 
    -- In order to detect and solve hazards, four status signal from the DataPath are used: STAT_S3_A_MATCH, STAT_S4_A_MATCH, STAT_S3_B_MATCH and STAT_S4_B_MATCH.
    -- When one of these signal is asserted, it means that a read operation on the register file has requested a register that is also in the write back pipeline
    -- for a previous instruction. The control unit checks if that instruction will actually write the RF by checking the value of CTRL_S5_RF_WR_EN.
    -- RAW and RAL hazard can't happen on S5 since the RF operates on CLK falling edge and so the updated value would be available before the end of 
    -- the clock cycle.
    -------------------------------------------------- 

    -- PURPOSE : detect and solve hazards
    -- TYPE : combinational
    -- INPUTS : STAT, CTRL_S3, CTRL_S4
    -- OUTPUTS : FWD_A_SEL, FWD_B_SEL, STALL
    HAZARD_P: process (STAT, CTRL_REG_S3, CTRL_REG_S4)
    begin 
        -- Forwarding A
        if(STAT(STAT_S3_A_MATCH)='1' and CTRL_REG_S3(CTRL_S5_RF_WR_EN)='1') then
            -- RAW hazard on A from S3
            FWD(FWD_A_EN) <= '1';
            FWD(FWD_A_SEL) <= '0';
        elsif(STAT(STAT_S3_A_MATCH)='1' and CTRL_REG_S3(CTRL_S5_RF_WR_EN)='1') then
            -- RAL hazard on A from S3
            FWD(FWD_A_EN) <= '0';
            FWD(FWD_A_SEL) <= '0';
        elsif(STAT(STAT_S4_A_MATCH)='1' and CTRL_REG_S4(CTRL_S5_RF_WR_EN)='1') then
            -- RAW hazard on A from S4
            FWD(FWD_A_EN) <= '1';
            FWD(FWD_A_SEL) <= '1';
        else
            -- No hazard
            FWD(FWD_A_EN) <= '0';
            FWD(FWD_A_SEL) <= '0';
        end if;

        -- Forwarding B
        if(STAT(STAT_S3_B_MATCH)='1' and CTRL_REG_S3(CTRL_S5_RF_WR_EN)='1') then
            -- RAW hazard on B from S3
            FWD(FWD_B_EN) <= '1';
            FWD(FWD_B_SEL) <= '0';
        elsif(STAT(STAT_S3_B_MATCH)='1' and CTRL_REG_S3(CTRL_S5_RF_WR_EN)='1') then
            -- RAL hazard on B from S3
            FWD(FWD_B_EN) <= '0';
            FWD(FWD_B_SEL) <= '0';
        elsif(STAT(STAT_S4_B_MATCH)='1' and CTRL_REG_S4(CTRL_S5_RF_WR_EN)='1') then
            -- RAW hazard on B from S4
            FWD(FWD_B_EN) <= '1';
            FWD(FWD_B_SEL) <= '1';
        else
            -- No hazard
            FWD(FWD_B_EN) <= '0';
            FWD(FWD_B_SEL) <= '0';
        end if;

        -- Stall
        if((STAT(STAT_S3_A_MATCH)='1' or STAT(STAT_S3_B_MATCH)='1') and CTRL_REG_S3(CTRL_S4_DRAM_RD_EN)='1') then
            -- RAL hazard on S3
            STALL <= '1';
        else
            STALL <= '0';
        end if;
    end process HAZARD_P;

    -- When stall is active, FETCH operations must be disabled
    FETCH <= not STALL;
end BEHAVIOURAL;

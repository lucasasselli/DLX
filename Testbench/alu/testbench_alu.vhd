library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_ALU is
    -- Empty
    end TB_ALU;

architecture TEST of TB_ALU is

    component MOCK_ALU is
        port (
            A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
            RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
        );
    end component;

    component ALU is
        port (
            A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
            AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
            RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
        );
    end component;

    signal A : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal B : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal AOP : std_logic_vector(AOP_SIZE_c-1 downto 0);

    signal RES : std_logic_vector(WORD_SIZE_c-1 downto 0);
    signal RES_MOCK : std_logic_vector(WORD_SIZE_c-1 downto 0);

    signal OK : std_logic;

begin

    AOP_P : process
        variable I : integer;
    begin
        for I in 0 to 18 loop
            wait for 100 ps;
            AOP <= std_logic_vector(to_unsigned(I, AOP_SIZE_c));
        end loop;
    end process;

    MAIN_P : process
        variable SEED1 : std_logic_vector(WORD_SIZE_c-1 downto 0) := "00010010111110010111000110000000";
        variable SEED2 : std_logic_vector(WORD_SIZE_c-1 downto 0) := "00010010111110010111000110000000";
    begin
        SEED1 := SEED1 xor std_logic_vector(signed(SEED1) sll 12);
        SEED1 := SEED1 xor std_logic_vector(signed(SEED1) srl 25);
        SEED1 := SEED1 xor std_logic_vector(signed(SEED1) sll 11);

        SEED2 := SEED2 xor std_logic_vector(signed(SEED2) sll 19);
        SEED2 := SEED2 xor std_logic_vector(signed(SEED2) srl 10);
        SEED2 := SEED2 xor std_logic_vector(signed(SEED2) sll 8);

        A <= SEED1;
        B <= SEED2;

        wait for 1900 ps;

    end process;
     
    ALU_I : ALU
    port map (
        A => A,
        B => B,
        AOP => AOP,
        RES => RES
    );

    MOCK_ALU_0 : MOCK_ALU
    port map (
        A => A,
        B => B,
        AOP => AOP,
        RES => RES_MOCK
    );

    OK <= '1' when RES_MOCK = RES else '0';

end TEST;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.globals.all;

entity MOCK_ALU is
    port (
        A : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        B : in std_logic_vector(WORD_SIZE_c-1 downto 0);
        AOP : in std_logic_vector(AOP_SIZE_c-1 downto 0);
        RES : out std_logic_vector(WORD_SIZE_c-1 downto 0)
    );
end MOCK_ALU;

architecture BEHAVIORAL of MOCK_ALU is
    constant TRUE_WORD_c : std_logic_vector(WORD_SIZE_c-1 downto 0) := (WORD_SIZE_c-1 downto 1 => '0') & '1';
    constant FALSE_WORD_c : std_logic_vector(WORD_SIZE_c-1 downto 0) := (others => '0');

begin

    P_ALU: process (AOP, A, B)
    begin
        if(AOP = AOP_NOP) then
            RES <= std_logic_vector(signed(A)+signed(B)); 
        elsif(AOP = AOP_ADD) then
            RES <= std_logic_vector(signed(A)+signed(B));
        elsif(AOP = AOP_SUB) then
            RES <= std_logic_vector(signed(A)-signed(B)); 
        elsif(AOP = AOP_AND) then 
            RES <= A and B;
        elsif(AOP = AOP_OR) then
            RES <= A or B;
        elsif(AOP = AOP_XOR) then
            RES <= A xor B;
        elsif(AOP = AOP_SEQ) then
            if(A = B) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SNE) then
            if(A /= B) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SGE) then
            if(signed(A) >= signed(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SGEU) then
            if(unsigned(A) >= unsigned(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SGT) then
            if(signed(A) > signed(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SGTU) then
            if(unsigned(A) > unsigned(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SLE) then
            if(signed(A) <= signed(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SLEU) then
            if(unsigned(A) <= unsigned(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SLT) then
            if(signed(A) < signed(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SLTU) then
            if(unsigned(A) < unsigned(B)) then 
                RES <= TRUE_WORD_c; 
            else 
                RES <= FALSE_WORD_c; 
            end if;
        elsif(AOP = AOP_SLL) then
            RES <= to_stdlogicvector(to_bitvector(A) sll to_integer(unsigned(B(SHIFT_VAL_SIZE_c-1 downto 0))));
        elsif(AOP = AOP_SRL) then
            RES <= to_stdlogicvector(to_bitvector(A) srl to_integer(unsigned(B(SHIFT_VAL_SIZE_c-1 downto 0))));
        elsif(AOP = AOP_SRA) then
            RES <= to_stdlogicvector(to_bitvector(A) sra to_integer(unsigned(B(SHIFT_VAL_SIZE_c-1 downto 0))));
        else
            RES <= (others => '0');
        end if; 
    end process P_ALU;
end BEHAVIORAL;

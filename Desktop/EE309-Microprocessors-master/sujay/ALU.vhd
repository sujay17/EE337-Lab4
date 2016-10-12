library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity alu is
 	port ( 
 alu_in_a : in signed(15 downto 0);
 alu_in_b : in signed(15 downto 0);
 alu_function : in STD_LOGIC_VECTOR (1 downto 0);
 alu_opcode : in std_logic_vector (3 downto 0); 
 alu_write_en : in std_logic ; 
 reset : in std_logic ;
 alu_out : out signed(15 downto 0);
 zero_flag, carry_flag : out std_logic );

end alu;
 
architecture Behavioral of alu is

signal alu_out : signed(15 downto 0);
signal zero_flag : std_logic ;
signal carry_flag : std_logic;

begin

process(alu_in_a, alu_in_b, alu_function, zero_flag, carry_flag, alu_opcode, alu_write_en, reset) 

begin
	if(alu_write_en)
	begin 
		case alu_function is

		 when "00" => -- addition operation 
			 adder:UnsignedSixteenBitAdder port map(A=>alu_in_a,B=>alu_in_b,C_in=>'1',Sum=>alu_out,C_out=>carry_flag);
			 if(alu_out="0000000000000000") then 
			    zero_flag <= '1' ;
			 else 
			 	zero_flag <= '0' ;
			 end if ;


		 when "01" =>  -- and operation 
		 	 nandoperation:Nand16 port map( a0=>alu_in_a, a1=>alu_in_b, b=>alu_out);
		 	 andoperation:Inverter16Bit port map (A=>alu_out,B=>alu_out) ;

		 	 if(alu_out="0000000000000000") then 
			    zero_flag <= '1' ;
			 else 
			 	zero_flag <= '0' ;
			 end if ;

		 when "10" =>
		 	 alu_out<= alu_in_a + 1; -- add 1 

		 when "11" => 
		 	null; --null 
		 
		end case; 
	
	else 

	  carry_flag <= carry_flag;
	  zero_flag <= zero_flag;
	  alu_out <= alu_out ;
  
end process; 
 
end Behavioral;







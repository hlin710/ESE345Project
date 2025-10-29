library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all; 
use work.all;

entity vhdltest is
	port(
		rs1 : in STD_LOGIC_VECTOR(127 downto 0);				-- 128-bit vector (input)
		rs2 : in STD_LOGIC_VECTOR(127 downto 0); 				-- 128-bit vector (input)
		rs3 : in STD_LOGIC_VECTOR(127 downto 0);				-- 128-bit vector (input)	
		instruction_format : in STD_LOGIC_VECTOR(24 downto 0); 	-- 25-bit vector (input)
		rd : out STD_LOGIC_VECTOR(127 downto 0) 				-- 128-bit vector (output)
	);
end vhdltest;

architecture behavioral of vhdltest is
begin

	process(all)
	-- variable opcode : STD_LOGIC_VECTOR(4 downto 0);          -- 5-bit opcode
	variable output : STD_LOGIC_VECTOR(127 downto 0);	    -- output register
	variable format_id : STD_LOGIC_VECTOR(1 downto 0);	    
											  
	-- R4 INSTRUCTION FORMAT FIELDS
	--variable long_mode : std_logic;
	variable li_sa_hl : STD_LOGIC_VECTOR(2 downto 0);
	
	constant signed_long_64_max : signed(64 downto 0) := to_signed(2**63 - 1, 65);
	constant signed_long_64_min : signed(64 downto 0) := to_signed(-2**63, 65);
	
											   
	
	variable product_long_64 : signed(63 downto 0);
	variable sum_long_64 : signed(64 downto 0);
	variable diff_long_64 : signed(64 downto 0);
							  
	begin
		format_id := instruction_format(24 downto 23);
		-- opcode := instruction_format(24 downto 20); 	-- Extract the first 5 bits for opcode
		output := (others => '0');					-- Clear output
		
				product_long_64 := (signed(rs2(31 downto 0)) * signed(rs3(31 downto 0)));
					sum_long_64 := resize(signed(rs1(63 downto 0)), 65) + resize(product_long_64, 65);		 
					
					if sum_long_64 > resize(signed_long_64_max, 65) then
						--output(64 downto 0) := std_logic_vector(sum_long_64);
						output(63 downto 0) := STD_LOGIC_VECTOR(resize(signed_long_64_max,64));
						 --output(63 downto 0) :=  std_logic_vector(product_long_64);
					elsif sum_long_64 < resize(signed_long_64_min, 65) then
						output(63 downto 0) := STD_LOGIC_VECTOR(resize(signed_long_64_min,64));
					else
						output(63 downto 0) := STD_LOGIC_VECTOR(sum_long_64(63 downto 0));
					end if;
					
					-- Word 1 [127:64]
					product_long_64 := signed(rs2(95 downto 64)) * signed(rs3(95 downto 64));
					sum_long_64 := resize(signed(rs1(127 downto 64)), 65) + resize(product_long_64, 65);
					
					if sum_long_64 > resize(signed_long_64_max, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(resize(signed_long_64_max,64));
					elsif sum_long_64 < resize(signed_long_64_min, 65) then
						output(127 downto 64) := STD_LOGIC_VECTOR(resize(signed_long_64_min,64));
					else
						output(127 downto 64) := STD_LOGIC_VECTOR(sum_long_64(63 downto 0));
					end if;
						
						rd <= output;
					
	end process;
end behavioral;
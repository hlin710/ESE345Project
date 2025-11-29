library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;


entity CPU_Top_Level is
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end CPU_Top_Level;

architecture structural of CPU_Top_Level is
    -- IF stage signals
    signal pc : unsigned(5 downto 0); -- PC address
    signal instr_if : std_logic_vector(24 downto 0); -- Instruction from IF
    -- IF/ID going into ID
    signal instr_id : std_logic_vector(24 downto 0);

    -- Decode + Regfile signals
    signal rs1_idx : unsigned(4 downto 0);
    signal rs2_idx : unsigned(4 downto 0);
    signal rs3_idx : unsigned(4 downto 0);
    signal rd_idx : unsigned(4 downto 0);
    signal imm16 : std_logic_vector(15 downto 0);
    signal opcode : std_logic_vector(7 downto 0);
    signal is_li_sig : std_logic;
    signal reg_write_sig : std_logic;
    signal uses_rs1_sig : std_logic;
    signal uses_rs2_sig : std_logic;
    signal uses_rs3_sig : std_logic;

    signal rs1_data : std_logic_vector(127 downto 0);
    signal rs2_data : std_logic_vector(127 downto 0);
    signal rs3_data : std_logic_vector(127 downto 0);

    -- ID/EX index outputs
    signal id_ex_rs1_idx : unsigned(4 downto 0);
    signal id_ex_rs2_idx : unsigned(4 downto 0);
    signal id_ex_rs3_idx : unsigned(4 downto 0);

    -- ID/EX latching signals (data)
    signal id_ex_rs1_data : std_logic_vector(127 downto 0);
    signal id_ex_rs2_data : std_logic_vector(127 downto 0);
    signal id_ex_rs3_data : std_logic_vector(127 downto 0);

    -- Latch the whole instruction into ID/EX for MALU (assumes ID_EX_Reg supports this)
    signal id_ex_instruction : std_logic_vector(24 downto 0);

    signal id_ex_imm16 : std_logic_vector(15 downto 0);
    signal id_ex_opcode : std_logic_vector(7 downto 0);

    signal id_ex_rd_idx : unsigned(4 downto 0);
    signal id_ex_regWrite : std_logic;
    signal id_ex_uses_rs3 : std_logic;
    signal id_ex_is_li : std_logic;

    -- Forwarding + Ex stage signals
    signal sel_rs1 : std_logic;
    signal sel_rs2 : std_logic;
    signal sel_rs3 : std_logic;

    signal opA : std_logic_vector(127 downto 0);
    signal opB : std_logic_vector(127 downto 0);
    signal opC : std_logic_vector(127 downto 0);

    signal alu_result : std_logic_vector(127 downto 0);

    -- EX/WB Stage Signals (used for WB + forwarding)
    signal ex_wb_rd_idx : unsigned(4 downto 0);
    signal ex_wb_result : std_logic_vector(127 downto 0);
    signal ex_wb_we : std_logic;

begin																
    -- IF Stage
    Program_Counter : entity work.Program_Counter
        port map(
            clk => clk,
            rst => rst,
            pc_freeze => '0',
            pc_out => pc
        );

    Instruction_Buffer: entity work.Instruction_Buffer
        port map(
            clk => clk,
            pc_addr => pc,
            instruction => instr_if,
            load_enable => '0',
            load_addr => (others => '0'),
            load_data => (others => '0')
        );

    IF_ID_Reg : entity work.IF_ID_Reg
        port map(
            clk => clk,
            rst => rst,
            ifid_freeze => '0',
            instruction_in => instr_if,
            instruction_out => instr_id
        );
																	   
    -- Decode Stage													 
    Decoder : entity work.Decode
        port map(
            instruction => instr_id,
            rs1_index => rs1_idx,
            rs2_index => rs2_idx,
            rs3_index => rs3_idx,
            rd_index => rd_idx,
            immediate16_out => imm16,
            opcode_out => opcode,
            is_li => is_li_sig,
            reg_write => reg_write_sig,
            uses_rs1 => uses_rs1_sig,
            uses_rs2 => uses_rs2_sig,
            uses_rs3 => uses_rs3_sig
        );

    -----------------------------------------------------------------
    -- Register File (reads)
    -----------------------------------------------------------------
    Register_File : entity work.Register_File
        port map(
            clk => clk,
            rst => rst,
            rs1_index => rs1_idx,
            rs2_index => rs2_idx,
            rs3_index => rs3_idx,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rs3_data => rs3_data,
            rd_index => ex_wb_rd_idx,  -- writeback from EX/WB
            rd_data => ex_wb_result,
            reg_write => ex_wb_we
        );

    -----------------------------------------------------------------
    -- ID/EX Register (latch data, indices, and control)
    -- (Assumes your ID_EX_Reg entity has index in/out and instruction in/out ports)
    -----------------------------------------------------------------
    ID_EX_Reg : entity work.ID_EX_Reg
        port map(
            clk => clk,
            rst => rst,
            idex_freeze => '0',

            -- data inputs
            rs1_in => rs1_data,
            rs2_in => rs2_data,
            rs3_in => rs3_data,

            -- index inputs (from Decode)
            rs1_index_in => rs1_idx,
            rs2_index_in => rs2_idx,
            rs3_index_in => rs3_idx,

            -- instruction and control inputs
            instruction_in => instr_id,        -- latch full instruction into ID/EX
            immediate16_in => imm16,
            opcode_in => opcode,
            rd_index_in => rd_idx,
            is_li_in => is_li_sig,
            reg_write_in => reg_write_sig,
            uses_rs3_in => uses_rs3_sig,

            -- outputs to EX stage
            rs1_out => id_ex_rs1_data,
            rs2_out => id_ex_rs2_data,
            rs3_out => id_ex_rs3_data,

            rs1_index_out => id_ex_rs1_idx,
            rs2_index_out => id_ex_rs2_idx,
            rs3_index_out => id_ex_rs3_idx,

            instruction_out => id_ex_instruction,
            immediate16_out => id_ex_imm16,
            opcode_out => id_ex_opcode,
            rd_index_out => id_ex_rd_idx,
            is_li_out => id_ex_is_li,
            reg_write_out => id_ex_regWrite,
            uses_rs3_out => id_ex_uses_rs3
        );

    -- Data Forwarding Block (decides which operands to forward) -
    Data_Forwarding_Block : entity work.Data_Forwarding_Block
        port map(
            idex_rs1 => id_ex_rs1_idx,
            idex_rs2 => id_ex_rs2_idx,
            idex_rs3 => id_ex_rs3_idx,
            idex_uses_rs3 => id_ex_uses_rs3,

            ex_wb_rd => ex_wb_rd_idx,
            ex_wb_regWrite => ex_wb_we,

            sel_rs1 => sel_rs1,
            sel_rs2 => sel_rs2,
            sel_rs3 => sel_rs3
        );


    -- Forwarding MUXs (apply forwarding from EX/WB result)			
    Forwarding_Muxs : entity work.Forwarding_MUXs
        port map(
            rs1_in => id_ex_rs1_data,
            rs2_in => id_ex_rs2_data,
            rs3_in => id_ex_rs3_data,
            opcode => id_ex_opcode,         -- unused by mux but left for compatibility

            EX_WB_res => ex_wb_result,
            rd_EX_WB_index => ex_wb_rd_idx, -- unused by mux (forwarding decision done upstream)

            sel_rs1 => sel_rs1,
            sel_rs2 => sel_rs2,
            sel_rs3 => sel_rs3,

            rs1_res => opA,
            rs2_res => opB,
            rs3_res => opC
        );
  
    -- MALU (Execute)												
    MALU : entity work.MALU
        port map(
            rs1 => opA,
            rs2 => opB,
            rs3 => opC,
            instruction_format => id_ex_instruction,
            rd => alu_result
        );
																	
    -- EX/WB Register (latch ALU result for writeback)		  
    EX_WB_Reg : entity work.EX_WB_Reg
        port map(
            clk => clk,
            rst => rst,
            exwb_freeze => '0',

            rd_result_in => alu_result,
            rd_index_in => id_ex_rd_idx,
            reg_write_in => id_ex_regWrite,

            rd_result_out => ex_wb_result,
            rd_index_out => ex_wb_rd_idx,
            reg_write_out => ex_wb_we
        );

end structural;

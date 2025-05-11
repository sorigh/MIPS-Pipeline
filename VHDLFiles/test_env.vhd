----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2024 11:58:45 AM
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
signal pcSrc: std_logic;
--signals for reg_file
signal wd : std_logic_vector(31 downto 0);

--signals for ifetch
signal digits:std_logic_vector(31 downto 0):=(others=>'0');
signal en_if:std_logic;
signal instruction:std_logic_vector(31 downto 0);
signal PC:std_logic_vector(31 downto 0);
signal branchAdr:std_logic_vector(31 downto 0);
--signals for UC
signal instr : std_logic_vector(5 downto 0);
signal regDest : std_logic;
signal extOp : std_logic;
signal aluSrc : std_logic;
signal branch :  std_logic;
signal jump :  std_logic;
signal aluOp : std_logic_vector(2 downto 0);
signal memWrite : std_logic;
signal memToReg : std_logic;
signal regWrite : std_logic;

--signals for ID
 signal rd1 : std_logic_vector(31 downto 0);
 signal rd2 : std_logic_vector(31 downto 0);
 signal sa : std_logic_vector(4 downto 0);
 signal func : std_logic_vector(5 downto 0);
 signal ext_imm : std_logic_vector(31 downto 0);


--signals for ex outputs
 signal zero : std_logic;
 signal aluRes : std_logic_vector(31 downto 0);
 signal branchAdress : std_logic_vector(31 downto 0);
 signal jumpAdress : std_logic_vector(31 downto 0);
 
 --signals for MEM outputs
 signal memData : std_logic_vector(31 downto 0);
 signal aluResOut  : std_logic_vector(31 downto 0);
 
 
 signal regDestMuxRez :std_logic_vector(4 downto 0);
 --signals for BIG REG
 signal REG_IF_ID:std_logic_vector(63 downto 0);
 signal REG_ID_EX:std_logic_vector(157 downto 0);
 signal REG_EX_MEM:std_logic_vector(106 downto 0);
 signal REG_MEM_WB:std_logic_vector(70 downto 0);
 
component MPG
    Port ( en : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0)
          );
end component;


component IFetch
    Port ( clk: in std_logic;
           en:in std_logic;
           rst: in std_logic;
           Jump: in std_logic;
           PCSrc: in std_logic;
           JumpAdr: in std_logic_vector(31 downto 0);
           BranchAdr: in std_logic_vector(31 downto 0);
           instruction: out std_logic_vector(31 downto 0);
           PC:out std_logic_vector(31 downto 0)
     );
end component;
component ID
     Port ( clk:in std_logic;
            validWrt:in std_logic;
            regWrite : in std_logic;
            regDst : in std_logic;
            extOp : in std_logic;
            instr : in std_logic_vector(25 downto 0);
            wd : in std_logic_vector(31 downto 0);
            
            rd1 : out std_logic_vector(31 downto 0);
            rd2 : out std_logic_vector(31 downto 0);
            ext_imm : out std_logic_vector(31 downto 0);
            func : out std_logic_vector(5 downto 0);
            sa : out std_logic_vector(4 downto 0)); --se duce in ex 
        
 end component;
 
 component UC
     Port ( instr : in std_logic_vector(5 downto 0);
            regDest : out std_logic;
            extOp : out std_logic;
            aluSrc : out std_logic;
            branch : out std_logic;
            jump : out std_logic;
            aluOp : out std_logic_vector(2 downto 0);
            memWrite : out std_logic;
            memToReg : out std_logic;
            regWrite : out std_logic);
     
 end component;
 
 component EX
     Port (  RD1 : in std_logic_vector(31 downto 0);
            RD2 : in std_logic_vector(31 downto 0);
            aluSrc : in std_logic;
            extImm : in std_logic_vector(31 downto 0);
            AluOp: in std_logic_vector(2 downto 0);
            pcPlus4: in std_logic_vector(31 downto 0);
            func : in std_logic_vector(5 downto 0);
            sa : in std_logic_vector(4 downto 0);
            
    
            zero : out std_logic;
          
            aluRes : out std_logic_vector(31 downto 0);
            branchAdress : out std_logic_vector(31 downto 0));
 end component;
 
 
 component MEM
 Port (  memWrite : in std_logic;
        aluResIn : in std_logic_vector(31 downto 0);
        rd2 : in std_logic_vector(31 downto 0);
        clk: in std_logic;
        en : in std_logic;
        memData : out std_logic_vector(31 downto 0);
        aluResOut  : out std_logic_vector(31 downto 0));
  end component;
begin

--portmap ssd
display:SSD port map (
clk=>clk,
digits=>digits,
an=>an,
cat=>cat);



--portmap IFETCH
InstructionFetch:IFetch port map
(
clk=>clk,
en=>en_if, --en facut prin mpg, legat de btn(0)
rst=>btn(1),
Jump=>Jump,
PCSrc=>PcSrc,
JumpAdr=>jumpAdress,
BranchAdr=>reg_EX_MEM(35 downto 4),--branchAdress,
instruction=>instruction,
PC=>PC -- pc+4 in PC merge apoi in ex
);

--portmap mpg pentru ifetch
btn_IFETCH:MPG port map
(
btn=>btn(0),
clk=>clk,
en=>en_if
);
-- ifetch controlat de switch(7)
--in pc se afla pc+4

--portmap ID
Instruction_Decoder: ID port map
(
    clk => clk,
    validWrt => en_if,
    regWrite => REG_MEM_WB(1), --regWrite, -- dus in UC
    regDst  => regDest, --dus in UC
    extOp  => extOp, -- dus in UC
    instr => REG_IF_ID(57 downto 32),--instruction(25 downto 0), 
    wd => wd,
    rd1 => rd1, --output din id dus in EX
    rd2 => rd2, -- output din ID dus in MEM
    ext_imm => ext_imm,
    func => func, 
    sa => sa
);


Control_Unit:UC port map
(
    instr => REG_IF_ID(63 downto 58), --instruction(31 downto 26),
    regDest => regDest,--id
    extOp => extOp, -- id
    aluSrc => aluSrc, --merge in ex
    branch => branch,
    jump => jump,
    aluOp => aluOp, --merge in ex
    memWrite => memWrite,
    memToReg => memToReg,
    regWrite => regWrite -- id
);


--portmap EX
Execution_Unit:EX port map
(
    --in
    RD1 =>REG_ID_EX(72 downto 41),-- rd1,
    RD2=> REG_ID_EX(104 downto 73), --rd2,
    aluSrc =>  REG_ID_EX(7),--aluSrc, --din uc
    extImm =>  REG_ID_EX(141 downto 110),--ext_imm, --din uc
    AluOp => REG_ID_EX(6 downto 4), --aluOp,
    pcPlus4=> REG_ID_EX(40 downto 9), --PC, --din ifetch
    func => REG_ID_EX(147 downto 142), --func, -- din id
    sa => REG_ID_EX(109 downto 105), --sa, -- din id
    
    --out
    zero => zero,
    aluRes => aluRes,
    branchAdress => branchAdress
);



--portmap Mem
Memory_Unit: MEM port map
(
    memWrite => REG_EX_MEM(2), --memWrite, --din uc
    aluResIn =>REG_EX_MEM(68 downto 37), --aluRes, -- din ex
    rd2 =>REG_EX_MEM(100 downto 69), --RD2, -- DIN ID
    clk => clk,
    en => en_if,
    memData => memData,
    aluResOut => aluResOut
);



--jumpAdress<=PC(31 downto 28)&instruction(25 downto 0)&"00";
jumpAdress<=REG_IF_ID(31 downto 28)&REG_IF_ID(57 downto 32)&"00";
PcSrc <= branch and zero;

process(regDest)
begin
if REG_ID_EX(8) = '0' then
    regDestMuxRez<= REG_ID_EX(152 downto 148);
else
    regDestMuxRez<= REG_ID_EX(157 downto 153);
end if;

end process;


process(wd)
begin
if REG_MEM_WB(0)='1' then --mem to reg
    wd<= REG_MEM_WB(33 downto 2); -- memData
else
    wd<= REG_MEM_WB(65 downto 34); --ALUResOut
end if;

end process;

process(clk)
begin
if clk='1' and clk'event then
REG_IF_ID(31 downto 0)<=PC; --pc+4 
REG_IF_ID(63 downto 32)<=instruction;
--wb
REG_ID_EX(0)<=memtoReg;
REG_ID_EX(1)<=RegWrite;
--m
REG_ID_EX(2)<=memWrite;
REG_ID_EX(3)<=branch;

--ex
REG_ID_EX(6 downto 4)<=aluOp;
REG_ID_EX(7)<=ALUSrc;
REG_ID_EX(8)<=RegDest;

REG_ID_EX(40 downto 9)<=REG_IF_ID(31 downto 0); --pc+4

REG_ID_EX(72 downto 41)<=RD1;
REG_ID_EX(104 downto 73)<=RD2;


REG_ID_EX(109 downto 105)<=sa; --instr[10-6]
REG_ID_EX(141 downto 110)<=Ext_Imm;
REG_ID_EX(147 downto 142)<=func;--func

--write adress initializat 
REG_ID_EX(152 downto 148)<=instruction(20 downto 16);
REG_ID_EX(157 downto 153)<=instruction(15 downto 11); 

--wb
REG_EX_MEM(1 downto 0)<=REG_ID_EX(1 downto 0);
--m
REG_EX_MEM(3 downto 2)<=REG_ID_EX(3 downto 2);

--mem
REG_EX_MEM(35 downto 4)<=BranchAdr;
REG_EX_MEM(36)<=zero;
REG_EX_MEM(68 downto 37)<=ALURes;
REG_EX_MEM(100 downto 69)<=RD2;
REG_EX_MEM(105 downto 101)<=regDestMuxRez;


REG_MEM_WB(1 downto 0) <=REG_EX_MEM(1 downto 0);
REG_MEM_WB(33 downto 2) <=memData;
REG_MEM_WB(65 downto 34)<= aluResOut;
REG_MEM_WB(70 downto 66)<= REG_EX_MEM(105 downto 101);
end if;
end process;


with sw(7 downto 5) select
digits <= Instruction when "000",
          pc when "001",
          rd1 when "010",
          rd2 when "011",
          ext_Imm when "100",
          ALURes when "101",
          MemData when "110",
          WD when "111",
          (others => 'X') when others;

end Behavioral;

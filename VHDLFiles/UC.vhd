----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2024 05:38:21 PM
-- Design Name: 
-- Module Name: UC - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC is
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
end UC;

architecture Behavioral of UC is

begin


process(instr)
begin
 regDest <= '0'; 
 regWrite <= '0';
 AluSrc <= '0';
 extOp <= '0';
 AluOp <= "000";
 MemWrite <= '0';
 MemToReg <= '0';
 branch <= '0';
 jump <= '0';
  case instr is
  --tip r
  --sll, slt, add, and
  when "000000" => regDest <= '1'; 
                   regWrite <= '1';
                   AluOp <= "010";
  --lw
  when "100011" => regWrite <= '1';
                   AluSrc <= '1';
                   extOp <= '1';
                   AluOp <= "000";
                   MemToReg <= '1';       
                   
  --sw
  when "101011" => 
                   
                   AluSrc <= '1';
                   extOp <= '1';
                   AluOp <= "000";
                   MemWrite <= '1';    
                    
  --addi
  when "001000" => 
                   regWrite <= '1';
                    AluSrc <= '1';
                    extOp <= '1';
                    AluOp <= "000";

  --beq
  when "000100" =>  extOp <= '1';
                    AluOp <= "001";
                    branch <= '1';
                   
  --j
  when "000010" => jump <= '1';   
  
                   
  --addiu
  when "010101" => regWrite <= '1';
                   AluSrc <= '1';
                   extOp <= '1';
                   AluOp <= "000";
  
  
  --lui
  when others =>  regWrite <= '1';
                   extOp <= '1';
                   AluOp <= "011";
  

                    
  end case;
end process;

end Behavioral;

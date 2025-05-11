----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2024 04:25:35 PM
-- Design Name: 
-- Module Name: ID - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID is
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
        sa : out std_logic_vector(4 downto 0));
        
end ID;

architecture Behavioral of ID is
signal wa: std_logic_vector(4 downto 0);


component reg_file
port ( 
clk : in std_logic;
ra1 : in std_logic_vector(4 downto 0);
ra2 : in std_logic_vector(4 downto 0);
wa : in std_logic_vector(4 downto 0);
wd : in std_logic_vector(31 downto 0);
regwr : in std_logic;
rd1 : out std_logic_vector(31 downto 0);
rd2 : out std_logic_vector(31 downto 0));
end component;

begin


--portmap reg file
register_file:reg_file port map
(
clk => clk,
ra1 => instr(25 downto 21),
ra2 => instr(20 downto 16),
wa => wa,
wd => wd,
regwr => regWrite,
rd1 => rd1,
rd2 => rd2
);


--in

process(regWrite, regDst, validWrt, instr)
begin
if regWrite = '1' and validWrt = '1' then
    if regDst = '1' then
        wa <= instr(15 downto 11);
        --wa <= instr(14 downto 0);
    else
        wa <= instr(20 downto 16);
    end if;
end if;
end process;
--out

sa <= instr(10 downto 6);
func <= instr(5 downto 0);
ext_imm(15 downto 0)<= instr(15 downto 0);
ext_imm(31 downto 16) <= (others => instr(15)) when extOp = '1' else (others => '0');


end Behavioral;

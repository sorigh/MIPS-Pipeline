----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2024 04:27:41 PM
-- Design Name: 
-- Module Name: IFetch - Behavioral
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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFetch is
Port (
clk: in std_logic;
en:in std_logic;
rst: in std_logic;
jump: in std_logic;
PCSrc: in std_logic;
JumpAdr: in std_logic_vector(31 downto 0);
BranchAdr: in std_logic_vector(31 downto 0);
instruction: out std_logic_vector(31 downto 0);
PC:out std_logic_vector(31 downto 0)
 );
end IFetch;

architecture Behavioral of IFetch is
signal PCsum:std_logic_vector(31 downto 0);
signal branchRez:std_logic_vector(31 downto 0);
--signal branch2Rez:std_logic_vector(31 downto 0);
signal PCin:std_logic_vector(31 downto 0);
signal PCout:std_logic_vector(31 downto 0);
type mem_rom is array(0 to 52)of std_logic_vector(31 downto 0);
signal rom: mem_rom:=(
-- aici cod
   0=>B"000100_00010_00000_0000000000001001",--X"4100 0009",beq $2,$0,9--inca nu a inceput iterarea
1=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
2=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
3=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
4=>B"001000_00000_01010_0000000000001011",--X"8028 000B",addi $10,$0,11--in reg 10 punem val 11
5=>B"101011_00010_01010_0000000000001011",--X"AC4A 000B",sw $10,4($2)--a[i] <-  10 in loc de 0
6=>B"000010_00000000000000000000101111",--X"0800 002F",j 47--inapoi la iterarea sirului
7=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
8=>B"100011_00000_00001_0000000000000000",--X"8C01 0000",lw $1, 0($0)--dimensiunea sirului n de la adresa 0
9=>B"001000_00000_01011_0000000000001011",--X"200B 000B",addi $11, $0, 11-- $11<- 10
10=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
11=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
12=>B"000000_01011_00001_00011_00000_101010",--X"0161 182A",slt $3, $11, $1--$3<- 1 daca n<val din $11, care e 10
13=>B"001010_00001_00011_0000000000001010",--X"2823 000A",slti $3,$1,10--$3<- 1 daca n<10
14=>B"100011_00000_00111_0000000000000001",--X"8C07 0001",lw $7, 1($0)-- punem in $7 o val de la adresa 1 pe care o vom scadea din elem sirului
15=>B"001000_00000_00011_0000000000000000",--X"2003 0000",addi $2,$0,0--$2 iteratorul pentru sir, i 
16=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
17=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
18=>B"000100_00001_00010_0000000000011000",--X"1022 0018",beq $1,$2,24-- salt daca suntem la finalul sirului
19=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
20=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
21=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
22=>B"100011_00010_00011_0000000000000100",--X"8C43 0004",lw $3, 4($2)-- $3 <- a[i]
23=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
24=>B"001000_00010_00011_0000000000000001",--X"2043 0001",addi $4,$2,1--$4<- i+1
25=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
26=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
27=>B"100011_00100_00101_0000000000000100",--X"8C85 0004",lw $5, 4($4)-- $5<- a[i+1]
28=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
29=>B"000000_00000_00000_0000000000000000",--X"0000 0000", NoOp
30=>B"000000_00100_00101_01000_00000_100100",--X"0085 4024",and $8,$4,$5-- si logic intre a[i] si a[i+1]
31=>B"000000_00100_00101_01001_00000_100101",--X"0085 4825",or $9,$4,$5-- sau logic intre a[i] si a[i+1]
32=>B"000000_00011_00100_00011_00000_100000",--X"0064 1820",add $3,$3,$4-- $3 <- a[i]+a[i+1], unde a[i] e in $3 si a[i+1] e in $4
33=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
34=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
35=>B"000000_00011_00100_00011_00000_100010",--X"0064 1822",sub $3,$3,$4-- $3 <- a[i]-$7, unde a[i] e in $3
36=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
37=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
38=>B"000000_00000_00011_00011_00001_000000",--X"0003 1840",sll $3,$3,1-- inmultim a[i]*2, unde a[i] e in $3
39=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
40=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
41=>B"000100_00001_00010_1111111111011000",--X"1022 FFD8",beq $3, $0, -40-- daca dupa operatii valoarea lui a[i] e 0, salt la inlocuire
42=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
43=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
44=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
45=>B"101011_00010_00011_0000000000000100",--X"AC43 0004",sw $3, 4($2)-- punem in memorie valoarea modificata a lui a[i] care era in $3
46=>B"001000_00010_00010_0000000000000001",--X"2042 0001",addi $2, $2, 1--incrementare iterator
47=>B"000100_00101_00001_0000000000000101",--X"10A1 0005",beq $5, $1, 5-- daca i+1 ar fi ultima valoare din sir, iesim
48=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
49=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
50=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp
51=>B"000010_00000000000000000000010010",--X"0800 0012",j 18-- repetare
52=>B"000000_00000_00000_0000000000000000",--X"0000 0000",NoOp

-----------------------------------------
    others => X"00000000"
    );                    

begin

--proces modificare pc in functie daca exista jump sau nu
branchRez<=PCsum when PCSrc='0' else BranchAdr;
PCin<=branchRez when Jump='0' else JumpAdr;

--bistabil PC
process(clk,rst)
begin
if rst='1' then
   PCout<=(others=>'0');
else
   if clk='1' and clk'event then
      if en='1'then
         PCout<=PCin;
      end if;
   end if;
end if;
end process;


--sumator
PCsum<= PCout+X"00000004";

PC<=PCsum;
--memorie rom
instruction<=rom(conv_integer(PCout(6 downto 2)));


end Behavioral;
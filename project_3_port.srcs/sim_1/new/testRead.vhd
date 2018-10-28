----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/10/28 10:49:05
-- Design Name: 
-- Module Name: testRead - Behavioral
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

entity testRead is
--  Port ( );
end testRead;

architecture Behavioral of testRead is
component readPort
port(
    clk,rst:in std_logic;
    input:inout std_logic_vector(7 downto 0);
    output:out std_logic_vector(7 downto 0);
    data_ready:in std_logic;
    rdn:out std_logic;
    output_state:out std_logic_vector(1 downto 0)
    );
end component;

signal testclk:std_logic:='0';
signal testrst:std_logic:='0';
signal testrdn:std_logic;
signal testready:std_logic:='1';
signal t_input:std_logic_vector(7 downto 0):="11111110";
signal t_output:std_logic_vector(7 downto 0);
signal t_state:std_logic_vector(1 downto 0);
constant t_time:time:=20ns;

begin
    test:readPort port map(testclk,testrst,t_input,t_output,testready,testrdn,t_state);
    
    fortime:process
    begin
        wait for t_time/2;
        testclk<=not testclk;
     end process fortime;
     
     forready:process
     begin
        wait for t_time*3;
        testready<=not testready;
    end process forready;
end Behavioral;

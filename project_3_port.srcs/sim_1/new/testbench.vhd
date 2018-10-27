----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/10/27 21:20:07
-- Design Name: 
-- Module Name: testbench - Behavioral
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

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
component WriteStateMachine
	port(
		clk, rst:in std_logic;
		input:in std_logic_vector(7 downto 0);
		output:out std_logic_vector(7 downto 0);
		tbre:in std_logic;
		tsre:in std_logic;
		wrn:out std_logic;
		output_state:out std_logic_vector(2 downto 0)
	);
end component;

signal my_clk:std_logic := '0';
signal my_rst:std_logic := '0';
signal my_tbre: std_logic :='0';
signal my_tsre: std_logic :='0';
signal my_wrn: std_logic;
signal my_input: std_logic_vector(7 downto 0):= "00001111";
signal my_output: std_logic_vector(7 downto 0);
signal my_output_state: std_logic_vector(2 downto 0);
constant clk_period:time := 20ns;

begin
	my_entity: WriteStateMachine
		port map(
			clk=>my_clk,
			rst=>my_rst,
			tbre=>my_tbre,
			tsre=>my_tsre,
			wrn=>my_wrn,
			input=>my_input,
			output=>my_output,
			output_state=>my_output_state
		);
	
	clk_gen: process
	begin
		wait for clk_period/2;
		my_clk <= not my_clk;
	end process clk_gen;
	
	tbre_and_tsre_gen: process
	begin
		wait for clk_period*5;
		my_tbre<='1';
		wait for clk_period*3;
		my_tsre<='1';
	end process tbre_and_tsre_gen;

end Behavioral;

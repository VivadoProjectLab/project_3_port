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
component PortController
	port(
		clk, rst:in std_logic; -- clk for start, rst for reset
		clk_auto:in std_logic; -- clk_auto for auto control of the write machine and the read machine
		switch:in std_logic_vector(7 downto 0);
		light:out std_logic_vector(7 downto 0);
		Ram1OE:out std_logic;
		Ram1WE:out std_logic;
		Ram1EN:out std_logic;
		data_ready:in std_logic;
		tbre:in std_logic;
		tsre:in std_logic;
		wrn:out std_logic;
		rdn:out std_logic;
		Ram1Data:inout std_logic_vector(7 downto 0);
		output_state: out std_logic_vector(1 downto 0)
	);
end component;

signal my_clk:std_logic := '1';
signal my_rst:std_logic := '0';
signal my_clk_auto: std_logic := '1';
signal my_switch:std_logic_vector(7 downto 0):= "00001111";
signal my_data_ready:std_logic := '0';
signal my_tbre: std_logic :='0';
signal my_tsre: std_logic :='0';
signal my_wrn: std_logic;
signal my_light: std_logic_vector(7 downto 0);
signal my_Ram1Data:std_logic_vector(7 downto 0);
signal output_state:std_logic_vector(1 downto 0);
constant clk_period:time := 20ns;
constant clk_auto_period:time := 1ns;

begin
	my_entity: PortController
		port map(
			clk=>my_clk,
			rst=>my_rst,
			clk_auto=>my_clk_auto,
			switch=>my_switch,
			light=>my_light,
			data_ready=>my_data_ready,
			tbre=>my_tbre,
			tsre=>my_tsre,
			wrn=>my_wrn,
			Ram1Data=>my_Ram1Data,
			output_state=>output_state
		);
	
	clk_auto_gen: process
	begin
		wait for clk_auto_period/2;
		my_clk_auto<=not my_clk_auto;
	end process;
	
	clk_gen: process
	begin
		wait for clk_period/2;
		my_clk <= not my_clk;
	end process clk_gen;
	
	tbre_and_tsre_gen: process
	begin
		wait for clk_auto_period*6;
		my_tbre<=not my_tbre;
		wait for clk_auto_period*6;
		my_tsre<=not my_tsre;
	end process tbre_and_tsre_gen;

end Behavioral;

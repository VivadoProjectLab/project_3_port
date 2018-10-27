----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/10/27 20:47:41
-- Design Name: 
-- Module Name: WriteStateMachine - Behavioral
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

entity WriteStateMachine is
	port(
		clk, rst:in std_logic;
		input:in std_logic_vector(7 downto 0);
		output:out std_logic_vector(7 downto 0);
		tbre:in std_logic;
		tsre:in std_logic;
		wrn:out std_logic;
		output_state:out std_logic_vector(2 downto 0)
	);
end WriteStateMachine;

architecture Behavioral of WriteStateMachine is
	type state is (INITIALIZE, SETOUTPUT, SETWRN, WAITTBRE, WAITTSRE);
	signal next_state, rst_state, current_state: state;
	signal rst_n: std_logic;
begin
	rst_n<=not rst;
	rst_state<=INITIALIZE;
	output<=input;
	
	current_state_transform: process(clk, rst_n)
	begin
		if(rst_n = '0') then
			current_state<=rst_state;
		elsif rising_edge(clk) then
			current_state<=next_state;
		end if;
	end process current_state_transform;
	
	next_state_transform: process(current_state, tbre, tsre)
	begin
		case current_state is
			when INITIALIZE=>next_state<=SETOUTPUT;
			when SETOUTPUT=>next_state<=SETWRN;
			when SETWRN=>next_state<=WAITTBRE;
			when WAITTBRE=>
				if(tbre = '0') then
					next_state<=WAITTBRE;
				else
					next_state<=WAITTSRE;
				end if;
			when WAITTSRE=>
				if(tsre = '0') then
					next_state<=WAITTSRE;
				else
					next_state<=INITIALIZE;
				end if;
			when others=>next_state<=INITIALIZE;
		end case;
	end process next_state_transform;
	
	action_process: process(current_state)
	begin
		wrn<='1';
		output_state<="000";
		case current_state is
			when INITIALIZE=>wrn<='1';
				output_state<="001";
			when SETOUTPUT=>wrn<='0';
				output_state<="010";
			when SETWRN=>wrn<='1';
				output_state<="011";
			when WAITTBRE=>wrn<='1';
				output_state<="100";
			when WAITTSRE=>wrn<='1';
				output_state<="101";
			when others=>wrn<='1';
				output_state<="000";
		end case;
	end process action_process;

end Behavioral;

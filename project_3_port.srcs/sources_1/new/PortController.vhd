----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/10/28 10:11:53
-- Design Name: 
-- Module Name: PortController - Behavioral
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

entity PortController is
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
		output_state:out std_logic_vector(1 downto 0);
		output_write_state:out std_logic_vector(2 downto 0)
	);
end PortController;

architecture Behavioral of PortController is
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

component readPort
port(
    clk,rst:in std_logic;
    input:inout std_logic_vector(7 downto 0);
    output:out std_logic_vector(7 downto 0);
    data_ready:in std_logic;
    rdn:out std_logic;
    output_state:out std_logic_vector(2 downto 0)
);
end component;

-- Signal for this state machine
type state is (RESET, READ, WRITE);
signal next_state, rst_state, current_state: state;
signal rst_n: std_logic;
signal start_ready: std_logic;

-- Signal for write state machine
signal write_clk:std_logic;
signal write_rst:std_logic;
signal write_wrn:std_logic;
signal write_output:std_logic_vector(7 downto 0);
signal write_state:std_logic_vector(2 downto 0);

signal read_clk,read_rst:std_logic;
signal read_state:std_logic_vector(2 downto 0);
signal read_rdn:std_logic;


begin
	my_write_state_machine: WriteStateMachine
		port map(
			clk=>write_clk,
			rst=>write_rst,
			input=>switch,
			output=>write_output,
			tbre=>tbre,
			tsre=>tsre,
			wrn=>write_wrn,
			output_state=>write_state
		);
	
	read_state_machine: readPort
		port map(
			read_clk,
			read_rst,
			Ram1Data,
			light,
			data_ready,
			read_rdn,
			read_state
		);
	
	-- 控制总线与UART相连，与Ram1断开
	Ram1OE<='1';
	Ram1WE<='1';
	Ram1EN<='1';
	-- 一些其他的设置
	rst_state<=RESET;
	start_ready<=clk; -- start_ready信号，用于开始下一个周期
	output_write_state<=write_state;
	
	-- 状态转移（模板）
	current_state_transform: process(rst_n, clk_auto)
	begin
		if(rst_n = '0') then
			current_state<=rst_state;
		elsif rising_edge(clk_auto) then
			current_state<=next_state;
		end if;
	end process current_state_transform;
	
	next_state_transform: process(current_state, read_state, write_state, start_ready)
	begin
		case current_state is
			when RESET=>
				if(start_ready = '1') then
					next_state<=READ;
				else
					next_state<=RESET;
				end if;
			when READ=>
				if(read_state="110") then
					next_state<=WRITE;
				else
					next_state<=READ;
			end if;
			when WRITE=>
				if(write_state = "110") then
					next_state<=RESET;
				else
					next_state<=WRITE;
				end if;
			when others=>
				next_state<=RESET;
		end case;
	end process next_state_transform;
	
	action: process(current_state, clk_auto, write_wrn)
	begin
		write_clk<='0'; -- 未在WRITE状态时，write状态机时钟停止
		wrn<='1'; -- 未在WRITE状态时，保持UART的wrn为1
		rdn<='1'; -- 未在READ状态时，保持UART的rdn为1
		read_clk<='0';
		case current_state is
			when READ=>
				write_rst<='0';
				read_clk<=clk_auto;
				rdn<=read_rdn;
			when WRITE=>
				write_rst<='0';
				wrn<=write_wrn; -- 进入WRITE状态后，将write状态机输出的wrn输入到UART中
				write_clk<=clk_auto; -- 进入WRITE状态后，为write状态机提供时钟输出
			when others=>
				write_rst<='1';
				write_clk<='0';
				read_rst<='1';
				read_clk<='0';
				wrn<='1';
				rdn<='1';
		end case;
	end process action;
	
	output_state_process: process(current_state)
	begin
		output_state<="00";
		case current_state is
			when RESET=>output_state<="01";
			when READ=>output_state<="10";
			when WRITE=>output_state<="11";
			when others=>output_state<="00";
		end case;
	end process;
	
	Ram1DataControl: process(current_state, write_output)
	begin
		Ram1Data<="ZZZZZZZZ"; -- 当未在WRITE状态时，Ram1Data输出到UART的接口设为高阻
		case current_state is
			when WRITE=>
				Ram1Data<=write_output; -- 当进入WRITE后，Ram1Data向UART输出的信号应为WriteStateMachine输出的信号
			when others=>
				Ram1Data<="ZZZZZZZZ";
		end case;
	end process Ram1DataControl;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/10/28 09:41:28
-- Design Name: 
-- Module Name: readPort - Behavioral
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

entity readPort is
--  Port ( );
port(
    clk,rst:in std_logic;
    input:in std_logic_vector(7 downto 0);
    output:out std_logic_vector(7 downto 0);
    data_ready:in std_logic;
    rdn:out std_logic;
    output_state:out std_logic_vector(2 downto 0)
    );
end readPort;

architecture Behavioral of readPort is
type state is (INI,CACHE,SET,TEST,SHOW,FINISH);
signal current_state,next_state:state;
signal Nrst:std_logic;
begin
    Nrst<=not rst;
    get_next:process(current_state,data_ready)
    begin
        case current_state is
            when INI=>
                next_state<=CACHE;
            when CACHE=>
                next_state<=SET;
            when SET=>
                next_state<=TEST;
            when TEST=>
                if(data_ready='1') then
                    next_state<=SHOW;
                else
                    next_state<=SET;
                 end if;
            when SHOW=>
                next_state<=FINISH;
            when FINISH=>
                next_state<=FINISH;
            when others=>
                next_state<=INI;
         end case;
   end process get_next;
   
   state_trans:process(clk,Nrst)
    begin
        if(Nrst = '0') then
            current_state<=INI;
       elsif rising_edge(clk) then
            current_state<=next_state;
       end if;
    end process state_trans;
    
    action:process(current_state)
    begin
        output_state<="000";
        case current_state is
            when INI=>
                output_state<="001";
                rdn<='1';
            when CACHE=>
                output_state<="010";
                rdn<='1';
            when SET=>
                rdn<='1';
                --input<="ZZZZZZZZ";
                output_state<="011";
                
            when TEST=>
                output_state<="100";
                if (data_ready='1') then
                    rdn<='0';
                else
                    rdn<='1';
                end if;
            when SHOW=>
                output_state<="101";
                output<=input;
                rdn<='1';
            when FINISH=>
                output_state<="110";
                rdn<='1';
            when others=>
                output_state<="000";
                rdn<='1';
            end case;
     end process action; 
end Behavioral;

-------------------------------------------------------------------------------
--
-- Title       : main
-- Design      : project982
-- Author      : arash yousefi
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : main.vhd
-- Generated   : Thu Jun 18 20:11:20 2020
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : by arash yousefi
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {main} architecture {main}}

library IEEE;
library work;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.myPack.all;

entity main is 
	generic(Floor_sig_bit_count : integer := 4
	);
	port(
	List : in my_list (9 downto 0);
	List_item : in list_element; 
	Init_size : in integer;
	Want_to_append, interrupt : in std_logic; 
	interrupt_floor : in integer;
	Clk, Reset, start : in std_logic;
	Timer : out std_logic_vector (3 downto 0);
	Floor : out std_logic_vector (Floor_sig_bit_count-1 downto 0);
	LiftDir : out std_logic_vector (1 downto 0);
	LiftDoor : out std_logic
	);
	
end main;

--}} End of automatically maintained section

architecture main of main is
type state is (idle, floor_0, list_ended, going_up, going_down, waiting, wait_a_second, going_down_int, going_up_int, waiting_int, end_go_to_0, decision, dummy1, dummy2, dummy3, dummy4);		
type state_interrupt is (idle, received_interrupt);	
type state_append is (idle, appending);
signal present_state, next_state : state := idle;
signal present_state_int, next_state_int : state_interrupt := idle;	
signal present_state_app, next_state_app : state_append := idle;
signal T_REG, T_NEXT, counter1_reg, counter1_next, counter2_reg, counter2_next, list_index_reg, list_index_next, wait_time, current_floor_reg, current_floor_next : integer := 0;	
signal floor_sig : std_logic_vector (Floor_sig_bit_count-1 downto 0) := (others => '0'); 
--------- 
constant MAX_SIZE : integer := 101;
signal size, size_next : integer := 10;
signal Main_List : my_list (MAX_SIZE-1 downto 0);
---------
signal interrupt_done : std_logic := '0';
signal floor_of_interrupt : integer := 0;  

---------
constant VALUE_1_SEC : integer := 10;
constant INT_SECONDS : integer := 5; 
constant UP_DOWN_SECONDS : integer := 2; 
constant WAIT_A_LITTLE : integer := 3;
signal VALUE_DOWN, VALUE_UP : INTEGER := UP_DOWN_SECONDS*VALUE_1_SEC;	
signal VALUE_WAIT : INTEGER := 0;
signal VALUE_INT : INTEGER := INT_SECONDS*VALUE_1_SEC; 

--signal interrupt : integer := 0;	

---------------------

---------------------

begin
	-- process for sequential logic ---
	process(Clk, Reset)
	begin
		
		if Reset = '1' then
			present_state <= idle;
			present_state_int <= idle;
			present_state_app <= idle; 
			size <= Init_size; 
			current_floor_reg <= 0;
			
		elsif (Clk'event and Clk = '1') then
			present_state <= next_state;  
			counter1_reg <= counter1_next;
			counter2_reg <= counter2_next; 
			list_index_reg <= list_index_next;
			current_floor_reg <= current_floor_next;
			present_state_int <= next_state_int;
			T_REG <= T_NEXT; 
			present_state_app <= next_state_app;
			size <= size_next;
			
		end if;	  
		
	end process;  
	
	-------------- 
	-- a process for combinational logic ---
	process(present_state, present_state_int, counter1_reg, counter2_reg, list_index_reg, wait_time, current_floor_reg, start)
	variable temp1, temp2, temp3 : integer;
	begin
		case present_state is  
			
			when idle => 
			list_index_next <= 0;
			current_floor_next <= 0;
			
			if start = '1' then
				if Init_size = 0 then
					next_state <= idle;
				elsif Main_List(list_index_reg).floor_num = 0 then
					next_state <= floor_0;
					counter1_next <= 0;	
					VALUE_WAIT <= VALUE_1_SEC * Main_List(list_index_reg).wait_time; 
					counter2_next <= 0;
					T_NEXT <= Main_List(list_index_reg).wait_time;
				else
					next_state <= going_up;
					counter1_next <= 0;	 
				end if;
				--Main_List(9 downto 0) <= List(9 downto 0); 
			else
				next_state <= idle;
			end if;	
			floor_sig <= (others => '0');
			Timer <= (others => '0');
			LiftDir <= "00";
			LiftDoor <= '1';
			current_floor_next <= 0;
			
			
			when floor_0 =>
			temp1 := counter2_reg;
			temp1 := temp1 + 1;
			if temp1 < VALUE_WAIT then
				if temp1 mod VALUE_1_SEC = 0 then
					temp3 := T_REG;	
					temp3 := temp3 - 1;
					T_NEXT <= temp3;
				end if;
				counter2_next <= temp1;
				next_state <= floor_0;
			else					   
				------check	
				if present_state_int = received_interrupt then
					
					temp2 := list_index_reg;
					temp2 := temp2 + 1;
					list_index_next <= temp2;
					next_state <= wait_a_second;
					T_NEXT <= 1;
					counter2_next <= 0;
					
				else
					temp2 := list_index_reg;
					if temp2 >= size - 1 then
						counter1_next <= 0;
						next_state <= list_ended;
					else 
						temp2 := temp2 + 1;
						list_index_next <= temp2;
						counter1_next <= 0;
						if Main_List(temp2).floor_num > current_floor_reg then
							next_state <= going_up;	 
							counter1_next <= 0;
						elsif Main_List(temp2).floor_num = current_floor_reg then
							next_state <= waiting;	
							current_floor_next <= temp2;
							counter1_next <= 0;	
							VALUE_WAIT <= VALUE_1_SEC * Main_List(list_index_reg).wait_time; 
							counter2_next <= 0;	 
							T_NEXT <= Main_List(list_index_reg).wait_time;
						else
							---An invalid input	
							next_state <= idle;
							--next_state <= going_down;
						end if;
						
					end if;
				end if;
				
				
			end if;
			floor_sig <= std_logic_vector(to_unsigned(0, floor_sig'length));
			--Timer <= std_logic_vector(to_unsigned(VALUE_WAIT - counter2_reg, Timer'length)); 
			Timer <= std_logic_vector(to_unsigned(T_REG, Timer'length));
			LiftDir <= "00";
			LiftDoor <= '1'; 
			
			
			
			when going_up =>
			temp1 := counter1_reg;
			temp1 := temp1 + 1;	
			interrupt_done <= '0';
			---
			---
			if temp1 < VALUE_UP then
				counter1_next <= temp1;	
				next_state <= going_up;
			else
				if present_state_int = received_interrupt then
					temp2 := current_floor_reg;
					temp2 := temp2 + 1;
					current_floor_next <= temp2;
					next_state <= wait_a_second;
					T_NEXT <= 1;
					counter2_next <= 0;
					
				else
					temp2 := current_floor_reg;
					temp2 := temp2 + 1;
					if temp2 = Main_List(list_index_reg).floor_num then
						next_state <= waiting;	
						current_floor_next <= temp2;
						counter1_next <= 0;	
						VALUE_WAIT <= VALUE_1_SEC * Main_List(list_index_reg).wait_time; 
						counter2_next <= 0;
						T_NEXT <= Main_List(list_index_reg).wait_time;
					else
						next_state <= going_up;
						current_floor_next <= temp2;
						counter1_next <= 0;
					end if;	 
				end if;
				
			end if;	  
			
			floor_sig <= (others => '1');
			Timer <= (others => '0');
			LiftDir <= "01";
			LiftDoor <= '0'; 
				
				
			
			when going_down =>
			temp1 := counter1_reg;
			temp1 := temp1 + 1;
			interrupt_done <= '0';
			----
			if temp1 < VALUE_DOWN then
				counter1_next <= temp1;
				next_state <= going_down; 
			else
				if present_state_int = received_interrupt then
					temp2 := current_floor_reg;
					temp2 := temp2 - 1;
					current_floor_next <= temp2;
					next_state <= wait_a_second; 
					counter2_next <= 0;	 
					T_NEXT <= 1;
					
				else
					temp2 := current_floor_reg;
					temp2 := temp2 - 1;
					if temp2 = Main_List(list_index_reg).floor_num then
						next_state <= waiting;	
						current_floor_next <= temp2;
						counter1_next <= 0;	
						VALUE_WAIT <= VALUE_1_SEC * Main_List(list_index_reg).wait_time; 
						counter2_next <= 0;	 
						T_NEXT <= Main_List(list_index_reg).wait_time;
					else
						next_state <= going_down;
						current_floor_next <= temp2;
						counter1_next <= 0;
					end if;					
				end if;				
			 end if;  
			 
			floor_sig <= (others => '1');
			Timer <= (others => '0');
			LiftDir <= "10";
			LiftDoor <= '0'; 
		
			
			
			when waiting =>
			temp1 := counter2_reg;
			temp1 := temp1 + 1;
			if temp1 < VALUE_WAIT then
				if temp1 mod VALUE_1_SEC = 0 then
					temp3 := T_REG;	
					temp3 := temp3 - 1;
					T_NEXT <= temp3;
				end if;
				counter2_next <= temp1;
				next_state <= waiting;
			else					   
				------check	
				if present_state_int = received_interrupt then
					temp2 := list_index_reg;
					temp2 := temp2 + 1;
					list_index_next <= temp2;
					next_state <= wait_a_second;
					T_NEXT <= 1;
					counter2_next <= 0;
					
				else
					temp2 := list_index_reg;
					if temp2 >= size - 1 then
						counter1_next <= 0;
						next_state <= end_go_to_0;
					else 
						temp2 := temp2 + 1;
						list_index_next <= temp2;
						counter1_next <= 0;
						if Main_List(temp2).floor_num > current_floor_reg then
							next_state <= going_up;
						elsif Main_List(temp2).floor_num = current_floor_reg then
							next_state <= waiting;	
							counter1_next <= 0;	
							VALUE_WAIT <= VALUE_1_SEC * Main_List(temp2).wait_time; 
							counter2_next <= 0;	 
							T_NEXT <= Main_List(list_index_reg).wait_time;
						else
							next_state <= going_down;
						end if;
						
					end if;
				end if;
				
				
			end if;
			floor_sig <= std_logic_vector(to_unsigned(current_floor_reg, floor_sig'length));
			--Timer <= std_logic_vector(to_unsigned(VALUE_WAIT - counter2_reg, Timer'length)); 
			Timer <= std_logic_vector(to_unsigned(T_REG, Timer'length));
			LiftDir <= "00";
			LiftDoor <= '1'; 
			
			
			when end_go_to_0 =>	
			if current_floor_reg = 0 then
				next_state <= idle;	
				counter1_next <= 0;	 
				counter2_next <= 0;
			else
				temp1 := counter1_reg;
				temp1 := temp1 + 1;
				if temp1 < VALUE_DOWN then
					counter1_next <= temp1;
					next_state <= end_go_to_0;
				else					   
					temp2 := current_floor_reg;
					temp2 := temp2 - 1;
					if temp2 = 0 then
						next_state <= idle;	
						current_floor_next <= temp2;
						counter1_next <= 0;	
						--VALUE_WAIT <= VALUE_1_SEC * List(list_index_reg).wait_time; 
						counter2_next <= 0;
					else
						next_state <= end_go_to_0;
						current_floor_next <= temp2;
						counter1_next <= 0;
					end if;
					
				end if;
			end if;
			
			floor_sig <= (others => '1');
			Timer <= (others => '0');
			LiftDir <= "11";
			LiftDoor <= '0'; 
			
			
			
			when going_up_int => 
			temp1 := counter1_reg;
			temp1 := temp1 + 1;
			---
			---
			if temp1 < VALUE_UP then
				counter1_next <= temp1;
				next_state <= going_up_int;
			else					   
				temp2 := current_floor_reg;
				temp2 := temp2 + 1;
				if temp2 = floor_of_interrupt then
					next_state <= waiting_int;	
					current_floor_next <= temp2;
					counter1_next <= 0;	
					VALUE_WAIT <= VALUE_INT; 
					counter2_next <= 0;	 
					T_NEXT <= INT_SECONDS;
				else
					next_state <= going_up_int;
					current_floor_next <= temp2;
					counter1_next <= 0;
				end if;
				
			end if;	
			
			floor_sig <= (others => '1');
			Timer <= (others => '0');
			LiftDir <= "01";
			LiftDoor <= '0'; 
				
			
			
			when going_down_int =>
			temp1 := counter1_reg;
			temp1 := temp1 + 1;
			----
			----
			if temp1 < VALUE_DOWN then
				counter1_next <= temp1;
				next_state <= going_down_int;
			else					   
				temp2 := current_floor_reg;
				temp2 := temp2 - 1;
				if temp2 = floor_of_interrupt then
					next_state <= waiting_int;	
					current_floor_next <= temp2;
					counter1_next <= 0;	
					VALUE_WAIT <= VALUE_INT; 
					counter2_next <= 0;	 
					T_NEXT <= INT_SECONDS;
				else
					next_state <= going_down_int;
					current_floor_next <= temp2;
					counter1_next <= 0;
				end if;
				
			end if;	
			
			floor_sig <= (others => '1');
			Timer <= (others => '0');
			LiftDir <= "10";
			LiftDoor <= '0'; 
			
			
			when wait_a_second => 
			temp1 := counter2_reg;
			temp1 := temp1 + 1;
			if temp1 < VALUE_1_SEC then 
				counter2_next <= temp1;
				next_state <= wait_a_second;
			else
				temp3 := T_REG;	
				temp3 := temp3 - 1;
				T_NEXT <= temp3;
				counter1_next <= 0;
				if floor_of_interrupt > current_floor_reg then
					next_state <= going_up_int;
				elsif floor_of_interrupt = current_floor_reg then
					next_state <= waiting_int;
					counter1_next <= 0;	
					VALUE_WAIT <= VALUE_INT; 
					counter2_next <= 0;	 
					T_NEXT <= INT_SECONDS;
				else
					next_state <= going_down_int;
				end if;
			end if;
			
			
		   	floor_sig <= std_logic_vector(to_unsigned(current_floor_reg, floor_sig'length));
			--Timer <= (others => '0');
			Timer <= std_logic_vector(to_unsigned(T_REG, Timer'length));
			LiftDir <= "00";
			LiftDoor <= '0'; 
			
			
			when waiting_int =>
			temp1 := counter2_reg;
			temp1 := temp1 + 1;
			if temp1 < VALUE_INT then 
				if temp1 mod VALUE_1_SEC = 0 then
					temp3 := T_REG;	
					temp3 := temp3 - 1;
					T_NEXT <= temp3;
				end if;
				counter2_next <= temp1;
				next_state <= waiting_int;
			else
				next_state <= decision;	
				interrupt_done <= '1';
				counter2_next <= 0;
			end if;
			floor_sig <= std_logic_vector(to_unsigned(current_floor_reg, floor_sig'length));  
			--Timer <= std_logic_vector(to_unsigned(VALUE_INT - counter2_reg, Timer'length));
			Timer <= std_logic_vector(to_unsigned(T_REG, Timer'length));
			LiftDir <= "00";
			LiftDoor <= '1'; 
			
			
			when decision => 
			temp1 := counter2_reg;
			temp1 := temp1 + 1;
			if temp1 < WAIT_A_LITTLE then 
				counter2_next <= temp1;
				next_state <= decision;
			else
			
				------check	
				if present_state_int = received_interrupt then
					
					next_state <= wait_a_second;
					--T_NEXT <= 1;
					counter2_next <= 0;
					
				else
					temp2 := list_index_reg;
					if temp2 >= size - 1 then
						counter1_next <= 0;
						next_state <= end_go_to_0;
					else 
						------check	
						counter1_next <= 0;		
						if Main_List(list_index_reg).floor_num > current_floor_reg then
							next_state <= going_up;
						elsif Main_List(list_index_reg).floor_num = current_floor_reg then
							next_state <= waiting;	
							counter1_next <= 0;	
							VALUE_WAIT <= VALUE_1_SEC * Main_List(list_index_reg).wait_time; 
							counter2_next <= 0;	 
							T_NEXT <= Main_List(list_index_reg).wait_time;
						else
							next_state <= going_down;
						end if;		   
					end if;
				end if;	
			end if;
			
			floor_sig <= std_logic_vector(to_unsigned(current_floor_reg, floor_sig'length));
			--Timer <= std_logic_vector(to_unsigned(VALUE_WAIT - counter2_reg, Timer'length)); 
			Timer <= std_logic_vector(to_unsigned(0, Timer'length));
			LiftDir <= "00";
			LiftDoor <= '0';
			interrupt_done <= '0';
			
			
			when list_ended =>
			floor_sig <= (others => '0');
			Timer <= (others => '0');
			LiftDir <= "11";
			LiftDoor <= '0';
			next_state <= idle;
		
			
			when others =>
			floor_sig <= (others => '0');
			Timer <= (others => '0');
			LiftDir <= "00";
			LiftDoor <= '0';
			next_state <= idle;
			
		
		end case;
		
		
	end process;
	
	Floor <= std_logic_vector(to_signed(current_floor_reg, Floor'length)) when (present_state = waiting or present_state = waiting_int or present_state = wait_a_second or present_state = idle or present_state = floor_0 or present_State = decision) else (others => '1');
		
	-------------------------------------
	------------------------------------- 
	interrupt_handler : process(present_state_int, interrupt, interrupt_floor, interrupt_done)
	begin
		case present_state_int is
			when idle =>
			if interrupt = '1' then
				next_state_int <= received_interrupt;
				floor_of_interrupt <= interrupt_floor;
				
			else									 
				next_state_int <= idle;	
				floor_of_interrupt <= 0;
			end if;
			
			when received_interrupt =>
			if interrupt_done = '1' then
				next_state_int <= idle;
				floor_of_interrupt <= 0;
				
			else									 
				next_state_int <= received_interrupt;	
				--floor_of_interrupt <= 0;
			end if;
		end case;
			
			
	end process;
	
	-------------------------------------
	-------------------------------------	
	list_controller : process(present_state, present_state_app, Want_to_append, List_item, start, size, Init_size)	
	variable temp : integer;
	begin
		case present_state_app is
			when idle => 
			if present_state /= idle then
				if Want_to_append = '1' then
					next_state_app <= appending;
					temp := size;
					Main_List(temp) <= List_item;
					temp := temp + 1;
					size_next <= temp;
				else
					next_state_app <= idle;	
				end if;	
			else
				--Main_List(9 downto 0) <= List(9 downto 0); 	
				Main_List(Init_size - 1 downto 0) <= List(Init_size - 1 downto 0);
				
			end if;
			
			
			when appending =>	  
			if Want_to_append = '0' then
				next_state_app <= idle;
			else
				next_state_app <= appending;
			end if;
			
			when others =>
			next_state_app <= idle;
			
		end case;
		
	end process;
	
	-------------------------------------
	-------------------------------------
	

end main;

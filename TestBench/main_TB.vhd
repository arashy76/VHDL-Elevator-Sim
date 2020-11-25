library project982;
use project982.myPack.all;
library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity main_tb is
	-- Generic declarations of the tested unit
		generic(
		Floor_sig_bit_count : INTEGER := 4 );
end main_tb;

architecture TB_ARCHITECTURE of main_tb is
	-- Component declaration of the tested unit
	component main
		generic(
		Floor_sig_bit_count : INTEGER := 4 );
	port(
		List : in my_list(9 downto 0);
		List_item : in list_element;
		Init_size : in INTEGER;
		Want_to_append : in STD_LOGIC;
		interrupt : in STD_LOGIC;
		interrupt_floor : in INTEGER;
		Clk : in STD_LOGIC;
		Reset : in STD_LOGIC;
		start : in STD_LOGIC;
		Timer : out STD_LOGIC_VECTOR(3 downto 0);
		Floor : out STD_LOGIC_VECTOR(Floor_sig_bit_count-1 downto 0);
		LiftDir : out STD_LOGIC_VECTOR(1 downto 0);
		LiftDoor : out STD_LOGIC );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal List : my_list(9 downto 0);
	signal List_item : list_element;
	signal Init_size : INTEGER;
	signal Want_to_append : STD_LOGIC;
	signal interrupt : STD_LOGIC := '0';
	signal interrupt_floor : INTEGER;
	signal Clk : STD_LOGIC;
	signal Reset : STD_LOGIC;
	signal start : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal Timer : STD_LOGIC_VECTOR(3 downto 0);
	signal Floor : STD_LOGIC_VECTOR(Floor_sig_bit_count-1 downto 0);
	signal LiftDir : STD_LOGIC_VECTOR(1 downto 0);
	signal LiftDoor : STD_LOGIC;

	------
	signal the_list : my_list (9 downto 0);
	
	--i define clock period here
	constant CLK_PERIOD : time := 40ns;
	
	--signal definition
	signal psuedo_rand : std_logic_vector (31 downto 0);
	
	--bits number for interrupt
	constant interrupt_bit_1 : integer := 18;
	constant interrupt_bit_2 : integer := 11;	 
	constant interrupt_bit_3 : integer := 3;
	
	--interrupt floor bits count
	signal interrupt_floor_bits_count : integer := 5;
	
	--a signal for save the interrupt floor in bits
	signal int_floor_bits : std_logic_vector (interrupt_floor_bits_count-1 downto 0);
	
	--bit numbers for interrupt floor
	constant interrupt_floor_bit_0 : integer := 1;
	constant interrupt_floor_bit_1 : integer := 4;
	constant interrupt_floor_bit_2 : integer := 12;
	constant interrupt_floor_bit_3 : integer := 7;
	constant interrupt_floor_bit_4 : integer := 9;	
	
	--reset for random generator
	signal reset_rand : std_logic := '0';
	
	-----------------------------------
	function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
	begin
		return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
	end function;
	-----------------------------------
	

begin

	-- Unit Under Test port map
	UUT : main
		generic map (
			Floor_sig_bit_count => Floor_sig_bit_count
		)

		port map (
			List => List,
			List_item => List_item,
			Init_size => Init_size,
			Want_to_append => Want_to_append,
			interrupt => interrupt,
			interrupt_floor => interrupt_floor,
			Clk => Clk,
			Reset => Reset,
			start => start,
			Timer => Timer,
			Floor => Floor,
			LiftDir => LiftDir,
			LiftDoor => LiftDoor
		);

	-- i write a process for generating clock pulse 
   	Clock_process :process
   	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
   	end process;   
	 
	--process for determine the interrupt signals
	random_interrupt : process(psuedo_rand, clk, reset_rand)
	begin
		if rising_edge(clk) then
			if reset_rand='1' then
				psuedo_rand <= (others => '0');
			else
				psuedo_rand <= lfsr32(psuedo_rand);
			end if;
		end if;
		
	end process;
	
	   
	reset <= '1', '0' after 0.1ns; 
	reset_rand <= '0', '1' after CLK_PERIOD/2, '0' after CLK_PERIOD;
	
	the_list(0) <= (floor_num => 2, wait_time => 3);
	the_list(1) <= (floor_num => 5, wait_time => 2);
	the_list(2) <= (floor_num => 4, wait_time => 1);
	the_list(3) <= (floor_num => 4, wait_time => 1); 
	the_list(4) <= (floor_num => 7, wait_time => 4); 
	the_list(5) <= (floor_num => 1, wait_time => 1); 
	the_list(6) <= (floor_num => 5, wait_time => 7); 
	the_list(7) <= (floor_num => 3, wait_time => 3);  
	the_list(8) <= (floor_num => 8, wait_time => 2);
	the_list(9) <= (floor_num => 9, wait_time => 1);
	--the_list(10) <= (floor_num => 5, wait_time => 2);
	-----------
	Init_size <= 10;
	-----------
	List <= the_list;  
	----------
	start <= '0', '1' after 1ns;
	----  
	interrupt <= '0', '1' after 99ns, '0' after 114ns, '1' after 200ns, '0' after 220ns;
	--interrupt <= (psuedo_rand(interrupt_bit_1) and psuedo_rand(interrupt_bit_2) and psuedo_rand(interrupt_bit_3)) when (interrupt_floor > 0 and interrupt_floor < 2**Floor_sig_bit_count)else '0' after 20ns;
	----	
	--int_floor_bits <= psuedo_rand(interrupt_floor_bit_4)&psuedo_rand(interrupt_floor_bit_3)&psuedo_rand(interrupt_floor_bit_2)&psuedo_rand(interrupt_floor_bit_1)&psuedo_rand(interrupt_floor_bit_0);
	int_floor_bits <= '0'&psuedo_rand(interrupt_floor_bit_3)&psuedo_rand(interrupt_floor_bit_2)&psuedo_rand(interrupt_floor_bit_1)&psuedo_rand(interrupt_floor_bit_0);
	----
	interrupt_floor <= to_integer(unsigned(int_floor_bits));
	----
	Want_to_append <= '0', '1' after 75ns, '0' after 110ns, '1' after 200ns;
	-----								  
	List_item <= (floor_num => 12, wait_time => 3), (floor_num => 14, wait_time => 7) after 190ns;
	
	

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_main of main_tb is
	for TB_ARCHITECTURE
		for UUT : main
			use entity work.main(main);
		end for;
	end for;
end TESTBENCH_FOR_main;


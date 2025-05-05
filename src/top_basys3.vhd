library ieee;
 
  use ieee.std_logic_1164.all;
 
  use ieee.numeric_std.all;
 
 
entity top_basys3 is
 
    port(
 
        -- inputs
 
        clk     :   in std_logic; -- native 100MHz FPGA clock
 
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
 
        btnU    :   in std_logic; -- reset
 
        btnC    :   in std_logic; -- fsm cycle
 
        -- outputs
 
        led :   out std_logic_vector(15 downto 0);
 
        -- 7-segment display segments (active-low cathodes)
 
        seg :   out std_logic_vector(6 downto 0);
 
        -- 7-segment display active-low enables (anodes)
 
        an  :   out std_logic_vector(3 downto 0)
 
    );
 
end top_basys3;
 
architecture top_basys3_arch of top_basys3 is
 
	-- declare components and signals
 
	signal w_cycle : std_logic_vector(3 downto 0);
 
	signal w_clk : std_logic;
 
	signal w_sign : std_logic;
 
	signal w_hund : std_logic_vector(3 downto 0);
 
	signal w_tens : std_logic_vector(3 downto 0);
 
	signal w_ones : std_logic_vector(3 downto 0);
 
	signal w_data : std_logic_vector(3 downto 0);
 
	signal w_sel : std_logic_vector(3 downto 0);
 
	signal w_mux_o : std_logic_vector(7 downto 0);
 
	signal w_mux2_i : std_logic_vector(6 downto 0);
 
	signal w_A : std_logic_vector(7 downto 0);
 
	signal w_B : std_logic_vector(7 downto 0);
 
	signal w_result : std_logic_vector(7 downto 0);
	signal w_op      : std_logic_vector(2 downto 0);
    signal w_flags   : std_logic_vector(3 downto 0);

 
    component controller_fsm  is
 
		port (
 
            i_adv        : in  std_logic;  
 
            i_reset      : in  std_logic;
 
            o_cycle      : out std_logic_vector(3 downto 0)
 
		 );
 
	end component controller_fsm;
 
    component clock_divider is
 
        generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
 
                                                   -- Effectively, you divide the clk double this
 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
 
        port ( 	i_clk    : in std_logic;
 
                i_reset  : in std_logic;		   -- asynchronous
 
                o_clk    : out std_logic		   -- divided (slow) clock
 
        );   
 
    end component clock_divider;
    component twos_comp is
 
        ---
 
        port (
 
        i_bin   : in std_logic_vector(7 downto 0);
 
        o_sign  : out std_logic;
 
        o_hund  : out std_logic_vector(3 downto 0);
 
        o_tens  : out std_logic_vector(3 downto 0);
 
        o_ones  : out std_logic_vector(3 downto 0)
 
        );
 
     end component twos_comp;
    component TDM4 is
 
		generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
 
        Port ( i_clk		: in  STD_LOGIC;
 
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
 
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
 
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
 
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
 
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
 
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
 
	   );
 
	end component TDM4;
 
    component sevenseg_decoder is
 
        port (
 
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
 
            o_seg : out STD_LOGIC_VECTOR (6 downto 0)

 
        );
 
    end component sevenseg_decoder;
component ALU is
    Port (
        i_A      : in std_logic_vector(7 downto 0);
        i_B      : in std_logic_vector(7 downto 0);
        i_op     : in std_logic_vector(2 downto 0);
        o_result : out std_logic_vector(7 downto 0);
        o_flags  : out std_logic_vector(3 downto 0)
    );
end component;

 
begin
 
	-- PORT MAPS ----------------------------------------
 
    controller_fsm1 : controller_fsm
 
    port map(
 
        i_adv => btnC,
 
        i_reset => btnU,
 
        o_cycle => w_cycle
 
    );
 
	display_MUX : TDM4
 
     generic map (k_WIDTH => 4)
 
        port map (
 
            i_clk   => w_clk,
 
            i_D3    => "1111", --"1111",  -- unused display: off
 
            i_D2    => w_hund,--w_seg,  -- unused display: off -- leave unused switches UNCONNECTED. Ignore any warnings this causes.
 
            i_D1    => w_tens, --"1111",  -- unused display: off
 
            i_D0    => w_ones,   -- rightmost display: current floor
 
            o_data  => w_data,
 
            o_sel   => an
 
        );
 
    clkdiv_inst : clock_divider
 
    generic map (k_DIV => 25000000)
 
        port map (
 
            i_clk => clk,
 
            i_reset => btnU,
 
            o_clk => w_clk
 
            );
    ALU_inst: ALU
    port map (
        i_A      => w_A,
        i_B      => w_B,
        i_op     => w_op,
        o_result => w_result,
        o_flags  => w_flags
    );
 
    twos_comp1 : twos_comp
 
        port map(
 
            i_bin => w_mux_o,
 
            o_sign => w_sign,
 
            o_hund => w_hund,
 
            o_tens => w_tens,
 
            o_ones => w_ones
 
        );
 
    sevenseg_decoder1 : sevenseg_decoder
 
    port map(
 
            i_Hex => w_data,
 
            o_seg => w_mux2_i

 
        );
 
	-- CONCURRENT STATEMENTS ----------------------------
 
    led(3) <= w_cycle(3);
 
    led(2) <= w_cycle(2);
 
    led(1) <= w_cycle(1);
 
    led(0) <= w_cycle(0);
 
    w_A <= sw(7 downto 0) when w_cycle = "0001"
 
        else w_A;
 
    w_B <= sw(7 downto 0) when w_cycle = "0010"
 
        else w_B;
    w_op <= sw(2 downto 0) when w_cycle = "0011" 
        else w_op;  -- Only 3 LSBs used
end top_basys3_arch;
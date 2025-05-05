library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
 
entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;
 
    
architecture Behavioral of ALU is
 
    signal ALU_result : std_logic_vector (7 downto 0);
    signal Sum: std_logic_vector(7 downto 0);
    signal A_in, B_in : std_logic_vector(7 downto 0);
    signal Cin : std_logic;
    component ripple_adder is
    Port (
        A  : in  std_logic_vector(7 downto 0);
        B  : in  std_logic_vector(7 downto 0);
        Cin  : in  std_logic;
        Sum  : out std_logic_vector(7 downto 0)
    );
end component;
begin 


    process(i_A,i_B,i_op)
begin
    case(i_op) is
--Logical Addition
    when "000" =>
            A_in <= i_A;
            B_in <= i_B;
            Cin  <= '0';
            ALU_result <= Sum;

 
-- Logical Subtraction: A - B = A + (~B + 1)
    when "001" =>
        A_in <= i_A;
        B_in <= not i_B;   
        Cin  <= '1';
        ALU_result <= Sum;
    when "010" => 
    ALU_result <= i_A and i_B;
--Logical OR
    when "011" => 
    ALU_result <= i_A or i_B;
     -- Default case
     when others =>
           ALU_result <= (others => '0');
end case;
end process;
 
    adder_inst: ripple_adder port map (
        A   => A_in,
        B   => B_in,
        Cin => Cin,
        Sum => Sum
);
 
    o_result <= ALU_result;

end Behavioral;
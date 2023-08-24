library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

USE std.textio.all;
entity my_latest_shifter_v1_0 is
generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;
        LINE_LENGTH             : integer := 1920;
        
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_START_COUNT	: integer	:= 1
	);
	port (
		-- Users to add ports here
        rgb2gs : in std_logic;
        tuser_input : in std_logic;
        tuser_output :  out std_logic;
        --irq_checker : in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line
        
       -- irq_counter : out std_logic_vector(20 downto 0);
		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(23 downto 0);
		s00_axis_tstrb	: in std_logic_vector(2 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(23 downto 0);
		m00_axis_tstrb	: out std_logic_vector(2 downto 0);
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
		
	);
end my_latest_shifter_v1_0;

architecture arch_imp of my_latest_shifter_v1_0 is

	-- component declaration
	component my_latest_shifter_v1_0_S00_AXIS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(23 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector(2 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component my_latest_shifter_v1_0_S00_AXIS;

	component my_latest_shifter_v1_0_M00_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 1
		);
		port (
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(23 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector(2 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic;
		outer_control : in std_logic
		);
	end component my_latest_shifter_v1_0_M00_AXIS;
	
	component xilinx_simple_dual_port_1_clock_ram is
generic (
RAM_WIDTH : integer;
RAM_DEPTH : integer;
RAM_PERFORMANCE : string;
INIT_FILE : string
);
port
(
 addra : in std_logic_vector(10 downto 0);
 addrb : in std_logic_vector(10 downto 0);
 dina  : in std_logic_vector(RAM_WIDTH-1 downto 0);
 clka  : in std_logic;
 wea   : in std_logic;
 enb   : in std_logic;
 rstb  : in std_logic;
 regceb: in std_logic;
 doutb : out std_logic_vector(RAM_WIDTH-1 downto 0)
);

end component;

-- Instantiation
-- Uncomment the instantiation below when using
    
	
	type pixel_buffer_type is array (LINE_LENGTH-1 downto 0) of std_logic_vector(23 downto 0);
    signal pixel_buffer : pixel_buffer_type;
    signal outer_control : std_logic;
    signal pix_counter : integer;
    signal buffer_done : std_logic;
    type state is (IDLE, FBUFFER, STREAM, END_WAIT);
    signal current_state : state;
    signal m_data : std_logic_vector(23 downto 0);
    signal transfer_data : std_logic_vector(23 downto 0);
    signal gs_data : std_logic_vector(23 downto 0);
    signal waitcounter : integer;
    signal checker : std_logic;
    signal last_dummy : std_logic;
    signal first_last : std_logic;
    signal valid_dummy : std_logic;
    signal control : std_logic_vector (23 downto 0);
    signal grayscale_vector : std_logic_vector(7 downto 0);
    signal R,G,B,GS : std_logic_vector (7 downto 0);
    signal final_data : std_logic_vector (23 downto 0);
    signal tuser_counter : integer;
    signal tuser_shift_register : std_logic_vector (1941 downto 0);
    signal tvalid_register : std_logic;
    signal R_2 : std_logic_vector (7 downto 0);
    signal R_5 : std_logic_vector (7 downto 0);
    signal R_6 : std_logic_vector (7 downto 0);
    signal G_1 : std_logic_vector (7 downto 0);
    signal G_4 : std_logic_vector (7 downto 0);
    signal G_5 : std_logic_vector (7 downto 0);
    signal B_3 : std_logic_vector (7 downto 0);
    signal pix_counter_vector : std_logic_vector (10 downto 0);
    signal tvalid_ff : std_logic;
    signal tvalid_ff2 : std_logic;
    signal tuser_valid : std_logic;
    signal ready_valid : std_logic;
    signal valid_valid : std_logic;
    signal wat : std_logic;
    signal indice : integer;
    signal med_data : std_logic_vector(23 downto 0);
    signal irq_buffer : integer;
    signal addra : std_logic_vector(10 downto 0);
    signal addrb : std_logic_vector(10 downto 0);
    signal  dina  : std_logic_vector(23 downto 0);
    signal  clka  : std_logic;
    signal  wea   : std_logic;
    signal enb   : std_logic;
    signal  rstb  : std_logic;
    signal  regceb: std_logic;
    signal  doutb : std_logic_vector(23 downto 0);
    signal truth : std_logic;
    signal tlast_val :std_logic;
    signal tuser_redir :std_logic;
    signal ready_dummy : std_logic;
    signal valid_assert : std_logic;
    signal given_ready : std_logic;
    signal valid_value : std_logic;
    signal buffer_truth : std_logic;
    signal last_assert : std_logic;
    signal tuser_assert : std_logic;
    signal first_tuser : std_logic;
    signal last_assert_transition : std_logic;
begin

-- Instantiation of Axi Bus Interface S00_AXIS
my_shifter_ip_v1_0_S00_AXIS_inst : my_latest_shifter_v1_0_S00_AXIS
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
	)
	port map (
		S_AXIS_ACLK	=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> ready_dummy,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TSTRB	=> s00_axis_tstrb,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid
	);

-- Instantiation of Axi Bus Interface M00_AXIS
my_shifter_ip_v1_0_M00_AXIS_inst : my_latest_shifter_v1_0_M00_AXIS
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> valid_dummy,
		M_AXIS_TDATA	=> m_data,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> last_dummy,
		M_AXIS_TREADY	=> m00_axis_tready,
	    outer_control => outer_control
	);
    
    the_ram : xilinx_simple_dual_port_1_clock_ram
    generic map (
    RAM_WIDTH => 24,
    RAM_DEPTH => 1945,
    RAM_PERFORMANCE => "HIGH_PERFORMANCE",
     INIT_FILE => "" 
    )
      port map  (
     addra  => addra,
     addrb  => addrb,
     dina   => dina,
     clka   => clka,
     wea    => wea,
     enb    => enb,
     rstb   => rstb,
     regceb => regceb,
     doutb  => doutb
)   ;
	
	-- Add user logic here
	m00_axis_tlast <= last_assert or last_assert_transition when (s00_axis_aresetn = '1') else '0';
    tuser_output <= tuser_assert when (s00_axis_aresetn = '1') else '0';
	given_ready<= (ready_dummy and m00_axis_tready and valid_value);
	s00_axis_tready <= (given_ready or buffer_truth)  when (s00_axis_aresetn = '1') else '0';
	enb <= (given_ready or buffer_truth) and s00_axis_tvalid;
	wea <= (given_ready or buffer_truth) and s00_axis_tvalid;
	regceb <= given_ready;
	indice <= LINE_LENGTH-100+pix_counter when (pix_counter < 100) else pix_counter-100;
	addra <= std_logic_vector(to_unsigned(pix_counter , 11));
	addrb <= std_logic_vector(to_unsigned(indice , 11));
	valid_value <= valid_assert and s00_axis_tvalid;
	m00_axis_tvalid <= valid_value when (s00_axis_aresetn = '1') else '0';
	clka <= s00_axis_aclk;
	med_data <= gs_data when (rgb2gs = '1') else transfer_data;
	m00_axis_tdata <= (others => '0') when (s00_axis_aresetn = '0') else med_data;
	
	process(s00_axis_aclk)
	begin
    if (rising_edge(s00_axis_aclk)) then
       R_2 <=  std_logic_vector( unsigned(std_logic_vector'("00"& transfer_data(23 downto 18))));
       R_5 <=  std_logic_vector( unsigned(std_logic_vector'("00000"& transfer_data(23 downto 21))));
       R_6 <=  std_logic_vector( unsigned(std_logic_vector'("000000"& transfer_data(23 downto 22))));
       B_3 <= std_logic_vector( unsigned(std_logic_vector'("000" & transfer_data(15 downto 11))));
       G_1 <= std_logic_vector( unsigned(std_logic_vector'("0" & transfer_data(7 downto 1))));
       G_4 <= std_logic_vector( unsigned(std_logic_vector'("0000" & transfer_data(7 downto 4))));
       G_5 <= std_logic_vector( unsigned(std_logic_vector'("00000" & transfer_data(7 downto 5))));
       
       R <= std_logic_vector( unsigned(std_logic_vector'("00" & transfer_data(23 downto 18))) + unsigned(std_logic_vector'("00000" & transfer_data(23 downto 21))) + unsigned(std_logic_vector'("000000" & transfer_data(23 downto 22)))    );
       B <= std_logic_vector( unsigned(std_logic_vector'("000" & transfer_data(15 downto 11))));
	   G <= std_logic_vector( unsigned(std_logic_vector'("0" & transfer_data(7 downto 1))) + unsigned(std_logic_vector'("0000" & transfer_data(7 downto 4))) + unsigned(std_logic_vector'("00000" & transfer_data(7 downto 5)))    );
	   GS <= std_logic_vector( unsigned(R) + unsigned(G) + unsigned(B));	    --                                   R2                                                       R5                                                      R6                                                       G1                                               G4                                                         G5                                                      B3
	    
    	gs_data <= (GS & GS & GS);
    
    
       
        if (s00_axis_aresetn = '0' or m00_axis_aresetn = '0') then
            wat <= '0';
            pixel_buffer <= (others => (others => '0'));
            pix_counter <= 0;
            buffer_done <= '0';
            outer_control <= '0';
            buffer_truth <= '0';
            first_last <= '0';
            transfer_data <= (others => '0');
            tuser_counter <= 0;
            truth <= '0';
            tuser_shift_register <= (others => '0');
        else
        
       
        
      
        
       
         
       -- if (m00_axis_tready = '0' or m00_axis_tready = '1')   then
       -- ready_valid <= '1';
       -- end if;
        
      --  if (ready_valid = '1') then
      --  tready_shift_register <= (m00_axis_tready & tready_shift_register(1940 downto 1));
        
      --  end if;
        
        
        
        
            case (current_state) is 
            when IDLE => 
            pix_counter <= 0; 
            truth <= '0';
            tuser_redir <= '0';
            first_last <= '0'; 
            pixel_buffer <= (others => (others => '0'));
            
            
            
            outer_control <= '0';
            if (wat = '0') then
                wat <= '1';
            else
            
            if (s00_axis_tvalid ='1') then
                current_state <= FBUFFER;
              
                buffer_truth <= '1';
            else
                current_state <= IDLE;
            end if;
            end if;
            when FBUFFER =>
            outer_control <= '0';
            
            first_last <= '0';
           
                if not(pix_counter<1919) then
                    pix_counter <= 0;
                    checker <= '0';
                    current_state <= END_WAIT;
                    first_tuser <= '1';
                    tuser_assert <= '1';
                    buffer_truth <= '0';
                    tuser_redir <= '0';
                    outer_control <= '0';
                    
                else
                    dina <= s00_axis_tdata;
                    pix_counter <= pix_counter+1;
                    current_state <= FBUFFER;
                end if;               
            when STREAM =>
                
                if (valid_value = '1' and m00_axis_tready = '1') then
                    dina <= s00_axis_tdata;
                    transfer_data <= doutb;
                   if (pix_counter = 1918) then 
                    last_assert_transition <= '1';
                    last_assert <= '1';
                    pix_counter <= pix_counter+1;
                   elsif (last_assert_transition = '1') then
                    current_state <= END_WAIT;
                    valid_assert <= '0';
                    pix_counter <= 0;
                   else
                    pix_counter <= pix_counter+1;
                    
                
                       
                end if;
                end if;
                   
                    
                    
               
             when END_WAIT =>
                last_assert_transition <= '0';
                
                
                if (tuser_counter = 1079) then
                
                    if (pix_counter = 12) then
                        tuser_assert <= '1';
                        pix_counter <= pix_counter+1;
                    elsif (pix_counter = 13) then
                    last_assert <= '0';
                    pix_counter <= pix_counter+1;
                    elsif (pix_counter = 30) then
                    valid_assert <= '1';
                    pix_counter <= pix_counter+1;
                    elsif (pix_counter = 31) then
                        if (valid_value = '1' and m00_axis_tready = '1') then
                            tuser_assert <= '0';
                            tuser_counter <= 0;
                            pix_counter <= 1;
                            current_state <= STREAM;
                        else
                            current_state <= END_WAIT;
                        end if;
                    
                    else
                        pix_counter <= pix_counter + 1;
                    end if;
                    
               elsif (first_tuser = '1') then
                        if (pix_counter = 17) then 
                        valid_assert <= '1';
                        pix_counter <= pix_counter+1;
                    elsif (pix_counter = 18) then
                        if (valid_value = '1' and m00_axis_tready = '1') then
                        tuser_assert <= '0';
                        pix_counter <= 1;
                        first_tuser <= '0';
                        current_state <= STREAM;
                        tuser_counter <= 0;
                        else 
                        current_state <= END_WAIT;
                        end if;
                    
                    else
                        pix_counter <= pix_counter+1;
                     end if;
                    
               else
                    if (pix_counter = 20) then
                        pix_counter <= 0;
                        valid_assert <= '1';
                        tuser_counter <= tuser_counter +1;
                        current_state <= STREAM;
                    elsif (pix_counter = 5) then
                        last_assert <= '0';
                        pix_counter <= pix_counter+1;
                    else
                        pix_counter <= pix_counter + 1;
      
    
                
              
           end if;
           end if;
             when others => 
             current_state <= IDLE;
             end case;
             end if;
             end if;
          end process;

	-- User logic ends

end arch_imp;





package ram_pkg is
    function clogb2 (depth: in natural) return integer;
end ram_pkg;

package body ram_pkg is

function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;
return ret_val;
end function;

end package body ram_pkg;

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ram_pkg.all;
USE std.textio.all;

entity xilinx_simple_dual_port_1_clock_ram is
generic (
    RAM_WIDTH : integer := 24;                      -- Specify RAM data width
    RAM_DEPTH : integer := 1944;                    -- Specify RAM depth (number of entries)
    RAM_PERFORMANCE : string := "LOW_LATENCY";      -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    INIT_FILE : string := ""                     -- Specify name/location of RAM initialization file if using one (leave blank if not)
    );

port (
        addra : in std_logic_vector((10) downto 0);     -- Write address bus, width determined from RAM_DEPTH
        addrb : in std_logic_vector((10) downto 0);     -- Read address bus, width determined from RAM_DEPTH
        dina  : in std_logic_vector(RAM_WIDTH-1 downto 0);		  -- RAM input data
        clka  : in std_logic;                       			  -- Clock
        wea   : in std_logic;                       			  -- Write enable
        enb   : in std_logic;                       			  -- RAM Enable, for additional power savings, disable port when not in use
        rstb  : in std_logic;                       			  -- Output reset (does not affect memory contents)
        regceb: in std_logic;                       			  -- Output register enable
        doutb : out std_logic_vector(RAM_WIDTH-1 downto 0)   			  -- RAM output data
    );

end xilinx_simple_dual_port_1_clock_ram;

architecture rtl of xilinx_simple_dual_port_1_clock_ram is

constant C_RAM_WIDTH : integer := RAM_WIDTH;
constant C_RAM_DEPTH : integer := RAM_DEPTH;
constant C_RAM_PERFORMANCE : string := RAM_PERFORMANCE;
constant C_INIT_FILE : string := INIT_FILE;

signal doutb_reg : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others => '0');
type ram_type is array (C_RAM_DEPTH-1 downto 0) of std_logic_vector (C_RAM_WIDTH-1 downto 0);          -- 2D Array Declaration for RAM signal
signal ram_data : std_logic_vector(C_RAM_WIDTH-1 downto 0) ;

-- The folowing code either initializes the memory values to a specified file or to all zeros to match hardware

function initramfromfile (ramfilename : in string) return ram_type is
file ramfile	: text is in ramfilename;
variable ramfileline : line;
variable ram_name	: ram_type;
variable bitvec : bit_vector(C_RAM_WIDTH-1 downto 0);

begin
    for i in ram_type'range loop
        readline (ramfile, ramfileline);
        read (ramfileline, bitvec);
        ram_name(i) := to_stdlogicvector(bitvec);
    end loop;
    return ram_name;
end function;

function init_from_file_or_zeroes(ramfile : string) return ram_type is
begin
    if ramfile = "RAM_INIT.dat" then
        return InitRamFromFile("RAM_INIT.dat") ;
    else
        return (others => (others => '0'));
    end if;
end;
-- Following code defines RAM

signal ram_name : ram_type := init_from_file_or_zeroes(C_INIT_FILE);

begin

process(clka)
begin
    if(clka'event and clka = '1') then
        if(wea = '1') then
            ram_name(to_integer(unsigned(addra))) <= dina;
        end if;
        if(enb = '1') then
            ram_data <= ram_name(to_integer(unsigned(addrb)));
        end if;
    end if;
end process;

--  Following code generates LOW_LATENCY (no output register)
--  Following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing

no_output_register : if C_RAM_PERFORMANCE = "LOW_LATENCY" generate
    doutb <= ram_data;
end generate;

--  Following code generates HIGH_PERFORMANCE (use output register)
--  Following is a 2 clock cycle read latency with improved clock-to-out timing

output_register : if C_RAM_PERFORMANCE = "HIGH_PERFORMANCE"  generate
process(clka)
begin
    if(clka'event and clka = '1') then
        if(rstb = '1') then
            doutb_reg <= (others => '0');
        elsif(regceb = '1') then
            doutb_reg <= ram_data;
        end if;
    end if;
end process;

doutb <= doutb_reg;

end generate;

end rtl;

-- The following is an instantiation template for xilinx_simple_dual_port_1_clock_ram
-- Component Declaration
-- Uncomment the below component declaration when using
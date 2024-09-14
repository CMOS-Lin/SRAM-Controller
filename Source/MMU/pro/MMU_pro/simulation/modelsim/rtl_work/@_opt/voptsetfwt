library verilog;
use verilog.vl_types.all;
entity MMU is
    generic(
        DATA_BIT        : integer := 8;
        LOGIC_ADDR_BIT  : integer := 3;
        PHYSI_ADDR_BIT  : integer := 6;
        FRAME_BIT       : integer := 2;
        SRAM_PACK_BIT   : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        rw_ena          : in     vl_logic;
        addr            : in     vl_logic_vector;
        frame           : in     vl_logic_vector;
        wr_data         : in     vl_logic_vector;
        ready           : out    vl_logic;
        data_table_out  : out    vl_logic_vector(23 downto 0);
        rd_data         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_BIT : constant is 1;
    attribute mti_svvh_generic_type of LOGIC_ADDR_BIT : constant is 1;
    attribute mti_svvh_generic_type of PHYSI_ADDR_BIT : constant is 1;
    attribute mti_svvh_generic_type of FRAME_BIT : constant is 1;
    attribute mti_svvh_generic_type of SRAM_PACK_BIT : constant is 1;
end MMU;

library verilog;
use verilog.vl_types.all;
entity SRAM is
    generic(
        DATA_BIT        : integer := 64;
        ADDR_BIT        : integer := 6
    );
    port(
        clk             : in     vl_logic;
        wr_ena          : in     vl_logic;
        rd_ena          : in     vl_logic;
        addr            : in     vl_logic_vector;
        wr_data         : in     vl_logic_vector;
        rd_data         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_BIT : constant is 1;
    attribute mti_svvh_generic_type of ADDR_BIT : constant is 1;
end SRAM;
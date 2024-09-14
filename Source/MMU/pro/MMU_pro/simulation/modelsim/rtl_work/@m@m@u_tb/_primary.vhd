library verilog;
use verilog.vl_types.all;
entity MMU_tb is
    generic(
        DATA_BIT        : integer := 8;
        ADDR_BIT        : integer := 4;
        FRAME_BIT       : integer := 2
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_BIT : constant is 1;
    attribute mti_svvh_generic_type of ADDR_BIT : constant is 1;
    attribute mti_svvh_generic_type of FRAME_BIT : constant is 1;
end MMU_tb;

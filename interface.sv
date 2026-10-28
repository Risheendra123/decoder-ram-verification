`ifndef INTERFACE_SV
`define INTERFACE_SV
interface ram_inf(input clk);
logic rst,wr_en,rd_en;
logic [6:0]wr_addr,rd_addr;
logic [7:0] data_in;
logic  [7:0] data_out;
logic  valid;
//clocking block for write driver
clocking wrdrv@(posedge clk);
   default input #1 output #1;
   output rst;
   output wr_en;
   output wr_addr;
   output data_in;
endclocking

//clocking block for read driver
clocking rddrv@(posedge clk);
   default input #1 output #1;
   input data_out;
   input valid;
   output rd_en;
   output rd_addr;
endclocking
//clocking block for monitor
clocking mon_cb@(posedge clk);

   default input #1;
   input rst;
   input wr_en;
   input rd_en;
   input wr_addr;
   input rd_addr;
   input data_in;
   input data_out;
   input valid;
endclocking
//Modports for write driver, read driver and  write monitor and read monitor
modport WRITE_DRV(clocking wrdrv, input clk);
modport READ_DRV(clocking rddrv, input clk);
modport W_MONITOR(clocking mon_cb, input clk);
modport R_MONITOR(clocking mon_cb, input clk);
//modport for DUT
modport identifier (
	input rst, wr_en, rd_en,wr_addr,rd_addr,data_in,
	output  data_out,
	output valid
);
endinterface 
`endif
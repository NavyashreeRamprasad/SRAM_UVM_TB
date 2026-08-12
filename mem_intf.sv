`define WIDTH 32 
`define DEPTH 256
`define ADDR_WIDTH 8
interface mem_intf(input logic clk_i, rst_i);

logic [`ADDR_WIDTH-1:0] addr_i;
logic [`WIDTH-1:0] wdata_i;
logic wr_rd_i, valid_i;
logic [`WIDTH-1:0] rdata_o;
logic ready_o;

clocking bfm_cb@(posedge clk_i);
	default input #0 output #1;
	input rst_i;
	output addr_i, wdata_i; 
	output wr_rd_i, valid_i;
	input rdata_o, ready_o;
endclocking

clocking mon_cb@(posedge clk_i);
	default input #1;
	input rst_i;
	input addr_i, wdata_i, wr_rd_i, valid_i;
	input rdata_o, ready_o;
endclocking

endinterface

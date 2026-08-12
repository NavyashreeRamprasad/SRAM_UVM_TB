module memory(clk_i, rst_i, addr_i, wdata_i, rdata_o, wr_rd_i, valid_i, ready_o);
parameter WIDTH=32;
parameter DEPTH=256;
parameter ADDR_WIDTH=8;

input clk_i, rst_i; 
input [ADDR_WIDTH-1:0] addr_i;
input [WIDTH-1:0] wdata_i;
input wr_rd_i, valid_i;
output reg [WIDTH-1:0] rdata_o;
output reg ready_o;
integer i;

reg [WIDTH-1:0] mem [DEPTH-1:0];

// 3 types of operations are possible at any active edge of clock
always @(posedge clk_i) begin
if (rst_i == 1) begin
	rdata_o = 0;
	ready_o = 0;
	for (i = 0; i < DEPTH; i=i+1) begin
		mem[i] = 0;
	end
end
else begin
if (valid_i == 1) begin
	ready_o = 1;
	if (wr_rd_i == 1) begin
		mem[addr_i] = wdata_i;
	end
	else begin
		rdata_o = mem[addr_i];
	end
end
else begin
	ready_o = 0;
end
end
end
endmodule

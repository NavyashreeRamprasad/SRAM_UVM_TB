module top;
reg clk, rst;
mem_intf pif(clk, rst);


memory dut(
			.clk_i(pif.clk_i),
			.rst_i(pif.rst_i),
			.addr_i(pif.addr_i),
			.wdata_i(pif.wdata_i),
			.rdata_o(pif.rdata_o),
			.wr_rd_i(pif.wr_rd_i),
			.valid_i(pif.valid_i),
			.ready_o(pif.ready_o)
		  ); 

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	rst = 1;
	repeat(1) @(posedge clk);
	rst = 0;
	repeat(1) @(posedge clk);
	rst = 1;
	repeat(2) @(posedge clk);
	rst = 0;
end

initial begin
  uvm_config_db#(virtual mem_intf)::set(null, "*", "vif", pif);
  run_test("test_nwr_nrd_test");

end

//initial begin
//$dumpfile("1.vcd");
//$dumpvars(0);
//end
endmodule


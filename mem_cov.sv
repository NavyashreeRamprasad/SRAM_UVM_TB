class mem_cov extends uvm_subscriber#(mem_tx);
  mem_tx tx;
`uvm_component_utils(mem_cov)

  covergroup mem_cg; 
  ADDR: coverpoint tx.addr {
  	option.auto_bin_max = 4;
  }
  WR_RD: coverpoint tx.wr_rd {
  	bins WRITE = {1'b1};
  	bins READ = {1'b0};
  }
  CROSS: cross WR_RD,ADDR;
   endgroup

function new(input string name, uvm_component parent=null);
	super.new(name, parent);
	mem_cg = new();
endfunction

function void write(mem_tx t);
  $cast(tx, t);
  mem_cg.sample();
endfunction

  
endclass


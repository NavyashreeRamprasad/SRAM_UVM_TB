class mem_tx extends uvm_sequence_item;
rand bit [7:0] addr;
rand bit [31:0] wdata;
rand bit wr_rd;
     bit [31:0] rdata;


`uvm_object_utils_begin(mem_tx)
	`uvm_field_int(addr, UVM_ALL_ON)
	`uvm_field_int(wdata, UVM_ALL_ON)
	`uvm_field_int(wr_rd, UVM_ALL_ON)
  `uvm_field_int(rdata, UVM_ALL_ON)
`uvm_object_utils_end

function new(string name="");
	super.new(name);
endfunction
endclass

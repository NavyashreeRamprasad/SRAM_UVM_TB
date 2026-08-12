class mem_sqr extends uvm_sequencer#(mem_tx);
`uvm_component_utils(mem_sqr)

function new(string name, uvm_component parent);
  super.new(name,parent);
endfunction

endclass

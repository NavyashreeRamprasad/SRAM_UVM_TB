class mem_base_seq extends uvm_sequence#(mem_tx);
mem_tx tx, tx_t;
mem_tx txQ[$];
uvm_phase phase;
`uvm_object_utils(mem_base_seq)
  
function new(string name=""); 
	super.new(name); 
endfunction

task pre_body();
	phase = get_starting_phase(); 
	if (phase != null) begin
		phase.raise_objection(this);
		phase.phase_done.set_drain_time(this, 100);
	end
endtask

task post_body();
	if (phase != null) phase.drop_objection(this);
endtask
endclass

class test_1_wr extends mem_base_seq;
`uvm_object_utils(test_1_wr)

function new(string name="");
  super.new(name);
endfunction

task body();
	`uvm_do_with(req, {req.wr_rd==1'b1;})
endtask

endclass

class test_5_wr extends mem_base_seq;
`uvm_object_utils(test_5_wr)

function new(string name="");
  super.new(name);
endfunction

task body();
repeat(5) begin
	`uvm_do_with(req, {req.wr_rd==1'b1;})
end
endtask

endclass

class test_1_wr_1_rd extends mem_base_seq;
`uvm_object_utils(test_1_wr_1_rd)

function new(string name="");
  super.new(name);
endfunction

task body();
	`uvm_do_with(req, {req.wr_rd==1'b1;})
	tx_t = new req;
	`uvm_do_with(req, {req.wr_rd==1'b0; req.addr==tx_t.addr; req.wdata ==0;})
endtask
endclass

class test_5wr_5rd extends mem_base_seq;
`uvm_object_utils(test_5wr_5rd)

  function new(string name="");
    super.new(name);
endfunction

task body();
	repeat(5) begin
	`uvm_do_with(req, {req.wr_rd==1'b1;})
	tx_t = new req;
	txQ.push_back(tx_t);
end
repeat(5) begin
	tx_t = txQ.pop_front();
	`uvm_do_with(req, {req.wr_rd==1'b0; req.addr==tx_t.addr; req.wdata ==0;})
end
endtask
endclass

class test_nwr_nrd extends mem_base_seq;
`uvm_object_utils(test_nwr_nrd)

  function new(string name="");
    super.new(name);
endfunction

task body();
	repeat(common::N) begin
	`uvm_do_with(req, {req.wr_rd==1'b1;})
	tx_t = new req;
	txQ.push_back(tx_t);
end
repeat(common::N) begin
	tx_t = txQ.pop_front();
	`uvm_do_with(req, {req.wr_rd==1'b0; req.addr==tx_t.addr; req.wdata == 0;})
end
endtask


endclass

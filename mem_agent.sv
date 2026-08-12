class mem_agent extends uvm_agent;
mem_drv drv;
mem_sqr sqr;
mem_mon mon;
mem_cov cov;
`uvm_component_utils(mem_agent)

function new(string name, uvm_component parent);
  super.new(name,parent);
endfunction

function void build();
  drv = mem_drv::type_id::create("drv",this);
  sqr = mem_sqr::type_id::create("sqr",this);
  cov = mem_cov::type_id::create("cov",this);
  mon = mem_mon::type_id::create("mon",this);
endfunction

function void connect();
	drv.seq_item_port.connect(sqr.seq_item_export);
	mon.ap_port.connect(cov.analysis_export);
endfunction

endclass


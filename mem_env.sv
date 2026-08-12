class mem_env extends uvm_env;
mem_agent agent;
mem_scb scb;
`uvm_component_utils(mem_env)

function new(string name , uvm_component parent);
  super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
  agent = new("agent",this);
  scb = new("scoreboard",this);
endfunction

function void connect();
agent.mon.ap_port.connect(scb.analysis_imp);
endfunction

endclass


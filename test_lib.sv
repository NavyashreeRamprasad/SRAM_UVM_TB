class mem_base_test extends uvm_test;

  mem_env env;

  `uvm_component_utils(mem_base_test)

  function new(string name="mem_base_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = mem_env::type_id::create("env",this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_factory factory;
    super.end_of_elaboration_phase(phase);

    factory = uvm_factory::get();
    factory.print();
    uvm_top.print_topology();

  endfunction

endclass



class test_1_wr_test extends mem_base_test;

  `uvm_component_utils(test_1_wr_test)

  test_1_wr seq;

  function new(string name="test_1_wr_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = test_1_wr::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.agent.sqr);

    phase.drop_objection(this);

  endtask

endclass



class test_5_wr_test extends mem_base_test;

  `uvm_component_utils(test_5_wr_test)

  test_5_wr seq;

  function new(string name="test_5_wr_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = test_5_wr::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.agent.sqr);

    phase.drop_objection(this);

  endtask

endclass



class test_1_wr_1_rd_test extends mem_base_test;

  `uvm_component_utils(test_1_wr_1_rd_test)

  test_1_wr_1_rd seq;

  function new(string name="test_1_wr_1_rd_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = test_1_wr_1_rd::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.agent.sqr);

    phase.drop_objection(this);

  endtask

endclass



class test_5wr_5rd_test extends mem_base_test;

  `uvm_component_utils(test_5wr_5rd_test)

  test_5wr_5rd seq;

  function new(string name="test_5wr_5rd_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = test_5wr_5rd::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.agent.sqr);

    phase.drop_objection(this);

  endtask
endclass

class test_nwr_nrd_test extends mem_base_test;

  `uvm_component_utils(test_nwr_nrd_test)

  test_nwr_nrd seq;

  function new(string name="test_nwr_nrd_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = test_nwr_nrd::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    seq.start(env.agent.sqr);

    phase.drop_objection(this);

  endtask
endclass

class mem_drv extends uvm_driver#(mem_tx);
virtual mem_intf vif;

  `uvm_component_utils(mem_drv)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(virtual mem_intf)::get(this, "", "vif", vif);
    endfunction

  task run_phase(uvm_phase phase);
    //vif = top.pif;
    forever begin
      seq_item_port.get_next_item(req);
      drive_tx(req);
      `uvm_info("MEM_DRV", $sformatf("Got item:\n%s", req.sprint()), UVM_LOW);
      seq_item_port.item_done();
    end
  endtask

 task drive_tx(mem_tx tx);
  @(vif.bfm_cb);
  vif.bfm_cb.addr_i <= tx.addr;
  vif.bfm_cb.wr_rd_i <= tx.wr_rd;
	if (tx.wr_rd==1) 
    vif.bfm_cb.wdata_i <= tx.wdata;
	vif.bfm_cb.valid_i <= 1;
	wait (vif.bfm_cb.ready_o == 1);
  @(vif.bfm_cb);
	if (tx.wr_rd==0) 
    tx.rdata = vif.bfm_cb.rdata_o;
	vif.bfm_cb.addr_i <= 0;
	vif.bfm_cb.wdata_i <= 0;
	vif.bfm_cb.wr_rd_i <= 0;
	vif.bfm_cb.valid_i <= 0;
  endtask

endclass
     


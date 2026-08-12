class mem_mon extends uvm_monitor;
  uvm_analysis_port#(mem_tx) ap_port;
  virtual mem_intf vif;
  mem_tx tx;
  `uvm_component_utils(mem_mon)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_port = new("ap_port", this);
    uvm_config_db#(virtual mem_intf)::get(this, "", "vif", vif);

  endfunction

  
  task run_phase(uvm_phase phase);
  //vif = top.pif;
  forever begin
	@(vif.mon_cb);
	if (vif.mon_cb.valid_i && vif.mon_cb.ready_o) begin
  
		tx = new();
		tx.addr = vif.mon_cb.addr_i;
    tx.wr_rd = vif.mon_cb.wr_rd_i;

		if(vif.mon_cb.wr_rd_i)
      tx.wdata = vif.mon_cb.wdata_i;
    tx.rdata = vif.mon_cb.rdata_o;
	  //tx.print();
    `uvm_info("MEM_MON",
          $sformatf("Observed item:\n%s", tx.sprint()),
          UVM_LOW);
		ap_port.write(tx); 	
    end

end
endtask


endclass

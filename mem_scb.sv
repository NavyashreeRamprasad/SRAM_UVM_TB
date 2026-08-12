class mem_scb extends uvm_scoreboard;
`uvm_component_utils(mem_scb)
  
  uvm_analysis_imp #(mem_tx,mem_scb) analysis_imp;
  int asso[*];
  mem_tx tx;

function new(string name,uvm_component parent);
super.new(name,parent);
analysis_imp = new("analysis_imp",this);
endfunction

virtual function void write(mem_tx t);
  $cast(tx,t);
  if(tx.wr_rd==1) begin
    asso[tx.addr]=tx.wdata;
  end
  else begin
    if(tx.rdata==asso[tx.addr]) common::matching++;
    else common::mismatching++;
  end
endfunction


function void report_phase(uvm_phase phase);
if(common::matching !=0 && common::mismatching ==0 ) 
$display("------------testcase passed -----------------");
else
$display("------------testcase failed-----------------");
endfunction

endclass

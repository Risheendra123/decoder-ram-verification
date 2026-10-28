`ifndef RD_DRIVER_SV
`define RD_DRIVER_SV

`include "transaction.sv"
`include "done_txn.sv"
`include "interface.sv"


class rd_driver;
 virtual ram_inf.READ_DRV vif;
 int unsigned txn_count;
 mailbox #(transaction) rd_mbox;
 function new(virtual ram_inf.READ_DRV vif,mailbox #(transaction) rd_mbox,int transaction_number);
     this.vif=vif;
     this.rd_mbox=rd_mbox;
     this.txn_count=transaction_number;


 endfunction

task drive(transaction txn);
 @(vif.rddrv);
 vif.rddrv.rd_en<=1'b1;
 vif.rddrv.rd_addr<=txn.rd_addr;
 @(vif.rddrv);
 txn.data_out<=vif.rddrv.data_out;
 txn.valid<=vif.rddrv.valid;

 @(vif.rddrv);
 vif.rddrv.rd_en<=1'b0;
 vif.rddrv.rd_addr<=7'b0;

endtask



task run();//called by env
 transaction txn;
   forever begin
    rd_mbox.get(txn);
    drive(txn);
    txn_count++;
    $display("Read driver executed %0d transactions",txn_count);
   end
endtask

endclass

`endif
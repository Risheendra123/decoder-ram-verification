`ifndef WRITE_DRIVER_SV
`define WRITE_DRIVER_SV

`include "transaction.sv"
`include "done_txn.sv"
`include "interface.sv"
class wr_driver;
    //transaction txn;
    virtual ram_inf.WRITE_DRV vif;
    mailbox #(transaction) wr_mbox;
    int unsigned txn_count;
    function new(virtual ram_inf.WRITE_DRV vif,mailbox #(transaction) wr_mbox,int transaction_number);
        this.vif = vif;
        this.wr_mbox = wr_mbox;
        this.txn_count = transaction_number;
       /* this.txn_count = txn_count;
        txn_count=0;*/
        //txn =new();
       // txn =this.txn;
    endfunction
task reset();
$display("Applying reset ");
    @(vif.wrdrv);
    vif.wrdrv.rst <= 1'b0;
    vif.wrdrv.wr_en <= 1'b0;
    vif.wrdrv.wr_addr <= 7'b0;
    vif.wrdrv.data_in <= 8'b0;
endtask

task drive(transaction txn );
   $display("Executing from write driver");
   @(vif.wrdrv);
   vif.wrdrv.wr_en <=1'b1;
   vif.wrdrv.wr_addr <=txn.wr_addr;
   vif.wrdrv.data_in<=txn.data_in;
 @(vif.wrdrv);
   reset();
endtask

task run();//called by env
 transaction txn;
   forever begin
    wr_mbox.get(txn);
    drive(txn);
    txn_count++;
    $display("Write driver executed %0d transactions",txn_count);
   end
endtask

endclass

`endif
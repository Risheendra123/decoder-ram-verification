`ifndef WRITE_MONITOR_SV
`define WRITE_MONITOR_SV

`include "transaction.sv"
`include "done_txn.sv"
`include "interface.sv"


class wr_monitor;
virtual ram_inf.W_MONITOR vif;
mailbox #(transaction) sb_wr_mbox;
mailbox #(transaction) rm_wr_mbox;
int unsigned count;
function new(virtual ram_inf.W_MONITOR vif,mailbox #(transaction) sb_wr_mbox,mailbox #(transaction) rm_wr_mbox,int count);
    this.vif=vif;
    this.sb_wr_mbox=sb_wr_mbox;
    this.rm_wr_mbox=rm_wr_mbox;
    this.count=count;
    endfunction

task run();
 transaction txn;
    forever begin
        
        @(vif.mon_cb);
        txn=new();
        txn.wr_addr=vif.mon_cb.wr_addr;
        txn.data_in=vif.mon_cb.data_in;
        txn.wr_en=vif.mon_cb.wr_en;
        txn.valid=vif.mon_cb.valid;
        sb_wr_mbox.put(txn);
        rm_wr_mbox.put(txn);
        count++;
        $display("no of write transactions executed %0d",count);
        end
    
endtask
endclass

`endif
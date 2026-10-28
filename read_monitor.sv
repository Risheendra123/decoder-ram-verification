`ifndef RD_MONITOR_SV
`define RD_MONITOR_SV

`include "transaction.sv"
`include "done_txn.sv"
`include "interface.sv"


class rd_monitor;
virtual ram_inf.R_MONITOR vif;
mailbox #(transaction) sb_rd_mbox;
mailbox #(transaction) rm_rd_mbox;
int unsigned count;
function new(virtual ram_inf.R_MONITOR vif,mailbox #(transaction) sb_rd_mbox,mailbox #(transaction) rm_rd_mbox,int count);
    this.vif=vif;
    this.sb_rd_mbox=sb_rd_mbox;
    this.rm_rd_mbox=rm_rd_mbox;
    this.count=count;
    endfunction

task run();
 transaction txn;
    forever begin
        
        @(vif.mon_cb);
        txn=new();
        txn.rd_addr=vif.mon_cb.rd_addr;
        txn.data_out=vif.mon_cb.data_out;
        txn.rd_en=vif.mon_cb.rd_en;
        txn.valid=vif.mon_cb.valid;
        if (txn.valid==0)begin
            $display("Invalid transaction");
        end
        else begin
            $display("Valid transaction");
            count++;
        end
        sb_rd_mbox.put(txn);
        rm_rd_mbox.put(txn);
        $display("no of read transactions executed %0d",count);
        end
endtask
endclass

`endif
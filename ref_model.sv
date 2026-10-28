`ifndef REF_MODEL_SV
`define REF_MODEL_SV

`include "transaction.sv"
`include "done_txn.sv"
`include "interface.sv"


class ref_model;
 logic [7:0] mem[0:127];
 mailbox #(transaction)rm_wr_mbox;
 mailbox #(transaction)rm_rd_mbox;
 mailbox #(transaction)sb_ex_mbox;

 int unsigned wr_processed;
 int unsigned rd_processed;

function new(mailbox #(transaction)rm_wr_mbox,mailbox #(transaction)rm_rd_mbox,mailbox #(transaction)sb_ex_mbox);
 this.rm_wr_mbox=rm_wr_mbox;
 this.rm_rd_mbox=rm_rd_mbox;
 this.sb_ex_mbox=sb_ex_mbox;

endfunction

task  run_writes();
 transaction txn;
 $display("write task started ");
 forever begin
    rm_wr_mbox.get(txn);
    mem[txn.wr_addr]=txn.data_in;
    wr_processed++;
    $display("[write task] wr_addr=%0h data is %0h block address %0b and %0d",txn.wr_addr,txn.data_in,txn.wr_addr[6:5],txn.wr_addr[6:5]);
 end
endtask
 task  run_read();
 transaction txn;
 $display("read task started ");
 forever begin
    rm_rd_mbox.get(txn);
    txn.data_out=mem[txn.rd_addr];
    txn.valid=1'b1;
    sb_ex_mbox.put(txn);
    rd_processed++;
    $display("[read task] rd_addr=%0h data is %0h block address %0b and %0d",txn.rd_addr,txn.data_out,txn.rd_addr[6:5],txn.rd_addr[6:5]);
 end
    
endtask 
endclass

`endif
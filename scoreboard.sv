`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "transaction.sv"
`include "done_txn.sv"
`include "interface.sv"
class scoreboard;
 mailbox #(transaction) sb_rdmon_mbox;
 mailbox #(transaction) sb_rm_mbox;
 mailbox #(transaction) sb_wr_mbox;

 int unsigned pass_count;
 int unsigned fail_count;
 int unsigned write_count;

 function new(mailbox #(transaction) sb_rdmon_mbox,mailbox #(transaction) sb_rm_mbox,mailbox #(transaction) sb_wr_mbox);
  this.sb_rdmon_mbox=sb_rdmon_mbox;
  this.sb_rm_mbox=sb_rm_mbox;
  this.sb_wr_mbox=sb_wr_mbox;

 endfunction

 task run_check();
  transaction actual,expected;
  $display("SB started");
  forever begin
    sb_rdmon_mbox.get(actual);
    sb_rm_mbox.get(expected);
    match_check(actual,expected);
  end
 endtask

 function void match_check(transaction actual,transaction expected);
  bit addr_match;
  bit data_match;
  bit valid_match;

  addr_match=(actual.rd_addr==expected.rd_addr);
  data_match=(actual.data_out==expected.data_out);
  valid_match=(actual.valid==expected.valid);
    
    if (addr_match && data_match && valid_match )
    begin
        pass_count++;
        $display("SB PASS: Address:%0h | Data: %0h | valid: %0b ",actual.rd_addr,actual.data_out,actual.valid);
    end

    else begin
        fail_count++;
        if (!addr_match) begin
            $display("Adress Mismatch");
        end
        if (!data_match) begin
            $display("Data Mismatch");
        end
        if (!valid_match) begin
            $display("Valid Mismatch");
        end
    end

    $display("PASS COUNT:%0d |FAIL COUNT: %0d",pass_count,fail_count);
 endfunction
endclass

`endif
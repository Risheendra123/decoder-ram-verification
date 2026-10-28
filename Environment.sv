`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "transaction.sv"
`include "interface.sv"
`include "generator.sv"
`include "module_decoder_ram.sv"
`include "write_driver.sv"
`include "read_driver.sv"
`include "done_txn.sv"
`include "write_monitor.sv"
`include "read_monitor.sv"
`include "scoreboard.sv"
`include "ref_model.sv"


class environment;

//class handles
//generator gen;
wr_driver wr_drv;
rd_driver rd_drv;
wr_monitor wr_mon;
rd_monitor rd_mon;
scoreboard sb;
ref_model rm;
int transaction_number;
//mailbox handles

mailbox #(transaction) wr_drv_mbox;
mailbox #(transaction) rd_drv_mbox;
mailbox #(transaction) rm_wmon_mbox;
mailbox #(transaction) rm_rmon_mbox;
mailbox #(transaction) sb_wmon_mbox;
mailbox #(transaction) sb_rmon_mbox;
mailbox #(transaction) sb__rm_ex_mbox;

//interface handles
virtual ram_inf.WRITE_DRV vif_wr_drv;
virtual ram_inf.READ_DRV vif_rd_drv;
virtual ram_inf.W_MONITOR vif_wr_mon;
virtual ram_inf.R_MONITOR vif_rd_mon;


function new(virtual ram_inf.WRITE_DRV vif_wr_drv,virtual ram_inf.READ_DRV vif_rd_drv,virtual ram_inf.W_MONITOR vif_wr_mon,virtual ram_inf.R_MONITOR vif_rd_mon,int transaction_number,mailbox #(transaction) wr_drv_mbox,mailbox #(transaction) rd_drv_mbox,mailbox #(transaction) rm_wmon_mbox,mailbox #(transaction) rm_rmon_mbox,mailbox #(transaction) sb_wmon_mbox,mailbox #(transaction) sb_rmon_mbox,mailbox #(transaction) sb__rm_ex_mbox);
           this.vif_wr_drv=vif_wr_drv;
           this.vif_rd_drv=vif_rd_drv;
           this.vif_wr_mon=vif_wr_mon;
           this.vif_rd_mon=vif_rd_mon;
           this.transaction_number=transaction_number;

           this.wr_drv_mbox=wr_drv_mbox;
           this.rd_drv_mbox=rd_drv_mbox;
           this.rm_wmon_mbox=rm_wmon_mbox;
           this.rm_rmon_mbox=rm_rmon_mbox;
           this.sb_wmon_mbox=sb_wmon_mbox;
           this.sb_rmon_mbox=sb_rmon_mbox;
           this.sb__rm_ex_mbox=sb__rm_ex_mbox;


endfunction
//build
function void build();
// gen= new(wr_drv_mbox,rd_drv_mbox,transaction_number);
 wr_drv=new(vif_wr_drv,wr_drv_mbox,transaction_number);
 rd_drv=new(vif_rd_drv,rd_drv_mbox,transaction_number);
 wr_mon=new(vif_wr_mon,sb_wmon_mbox,rm_wmon_mbox,transaction_number);
 rd_mon=new(vif_rd_mon,sb_rmon_mbox,rm_rmon_mbox,transaction_number);
 sb=new(sb_rmon_mbox,sb__rm_ex_mbox,sb_wmon_mbox);
 rm=new(rm_wmon_mbox,rm_rmon_mbox,sb__rm_ex_mbox);
 $display("ALL COMPONENTS BUILT");
endfunction

task start();
fork
wr_drv.run();
rd_drv.run();
wr_mon.run();
rd_mon.run();
sb.run_check();
rm.run_writes();
rm.run_read();
$display("all Threads started to execute");
join
wr_drv.reset();

endtask

/*task run();
gen.run(transaction_number);
endtask*/

task  report();
    sb.run_check();
endtask
endclass

`endif
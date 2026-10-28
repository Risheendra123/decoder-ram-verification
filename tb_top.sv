// ============================================================
//  tb_top.sv  —  Top-Level Verification Testbench
// ============================================================
`timescale 1ns/1ps
`include "Environment.sv"
`include "transaction.sv"
`include "interface.sv"
`include "write_driver.sv"
`include "read_driver.sv"
`include "write_monitor.sv"
`include "read_monitor.sv"
`include "ref_model.sv"
`include "scoreboard.sv"
`include "test.sv"

module tb_top;

  // 1. Clock Generation (100 MHz -> 10 ns Period)
  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;

  // 2. Physical Interface Instantiation
  ram_inf inf(clk);
  //  Mailbox Allocation
  mailbox #(transaction) wr_mbox    = new();
  mailbox #(transaction) rd_mbox    = new();
  mailbox #(transaction) sb_wr_mbox = new();
  mailbox #(transaction) rm_wr_mbox = new();
  mailbox #(transaction) sb_rd_mbox = new();
  mailbox #(transaction) rm_rd_mbox = new();
  mailbox #(transaction) sb_ex_mbox = new();

  environment env;

  initial begin 
  env=new(
    inf.WRITE_DRV,
    inf.READ_DRV,inf.W_MONITOR,
    inf.R_MONITOR,
    100,
    wr_mbox,
    rd_mbox,
    rm_wr_mbox,
    rm_rd_mbox,
    sb_wr_mbox,
    sb_rd_mbox,
    sb_ex_mbox
    );
    env.build();
    env.start();
  end
  // 3. DUT Instantiation
  decoder_ram DUT (
    .clk      (inf.clk),
    .rst      (inf.rst),
    .wr_en    (inf.wr_en),
    .rd_en    (inf.rd_en),
    .wr_addr  (inf.wr_addr),
    .rd_addr  (inf.rd_addr),
    .data_in  (inf.data_in),
    .data_out (inf.data_out),
    .valid    (inf.valid)
  );

  

  // 5. Testbench Environment Components
 /* wr_driver  wr_drv = new(inf, wr_mbox);
  rd_driver  rd_drv = new(inf, rd_mbox);
  wr_monitor wr_mon = new(inf, sb_wr_mbox, rm_wr_mbox);
  rd_monitor rd_mon = new(inf, sb_rd_mbox, rm_rd_mbox);
  ref_model  rm     = new(rm_wr_mbox, rm_rd_mbox, sb_ex_mbox);
  scoreboard sb     = new(sb_rd_mbox, sb_ex_mbox, sb_wr_mbox);*/

  // Test Instances
  write_read_single_test t_single = new(wr_mbox, rd_mbox);
  boundary_test          t_bound  = new(wr_mbox, rd_mbox);
  block_isolation_test   t_iso    = new(wr_mbox, rd_mbox);
  full_mem_test          t_full   = new(wr_mbox, rd_mbox);
  random_stress_test     t_stress = new(wr_mbox, rd_mbox, 100);

  // 6. Reset Task
  task apply_reset();
    $display("[%0t] [TB_TOP] Asserting Active-Low Reset...", $time);
    inf.rst     <= 1'b0;
    inf.wr_en   <= 1'b0;
    inf.rd_en   <= 1'b0;
    inf.wr_addr <= 7'b0;
    inf.rd_addr <= 7'b0;
    inf.data_in <= 8'b0;
    repeat (5) @(posedge clk);
    inf.rst     <= 1'b1;
    $display("[%0t] [TB_TOP] Reset De-asserted.", $time);
  endtask

  // 7. Test Execution Sequence
  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);

    $display("==================================================");
    $display("       STARTING DECODER RAM VERIFICATION          ");
    $display("==================================================");

    apply_reset();

    // Fork Environment Verification Threads
   /* fork
      wr_drv.run();
      rd_drv.run();
      wr_mon.run();
      rd_mon.run();
      rm.run_writes();
      rm.run_read();
      sb.run_check();
    join_none*/

    //Verification Tasks:
    repeat (2) @(posedge clk);

    // Execute Tests Sequentially
    t_single.run();
    repeat (20) @(posedge clk);

    t_bound.run();
    repeat (20) @(posedge clk);

    t_iso.run();
    repeat (20) @(posedge clk);

    t_full.run();
    repeat (300) @(posedge clk);

    t_stress.run();
    repeat (300) @(posedge clk);

    // 8. Simulation Summary Report
    $display("\n==================================================");
    $display("               VERIFICATION SUMMARY               ");
    $display("  PASSED: %0d", env.sb.pass_count);
    $display("  FAILED: %0d", env.sb.fail_count);
    $display("==================================================");

    if (env.sb.fail_count == 0 && env.sb.pass_count > 0)
      $display("*** RESULT: ALL TESTS PASSED SUCCESSFULLY ***\n");
    else
      $display("*** RESULT: VERIFICATION FAILED (Check log) ***\n");

    $finish;
  end

  // Watchdog Timeout (Prevents endless simulation execution)
  initial begin
    #500000;
    $display("\n[WATCHDOG] ERROR: Simulation timeout reached!");
    $finish;
  end

endmodule
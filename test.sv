// ============================================================
//  test.sv  —  Test Case Suite for Decoded RAM
// ============================================================
`ifndef TEST_SV
`define TEST_SV

`include "transaction.sv"

// ------------------------------------------------------------
// Base Test Class
// ------------------------------------------------------------
virtual class base_test;
  mailbox #(transaction) wr_mbox;
  mailbox #(transaction) rd_mbox;

  function new(mailbox #(transaction) wr_mbox, mailbox #(transaction) rd_mbox);
    this.wr_mbox = wr_mbox;
    this.rd_mbox = rd_mbox;
  endfunction

  // Helper function: Build a Write Transaction
  function transaction make_write(logic [6:0] addr, logic [7:0] data);
    transaction t = new();
    t.op      = transaction::WRITE;
    t.wr_en   = 1'b1;
    t.rd_en   = 1'b0;
    t.wr_addr = addr;
    t.data_in = data;
    return t;
  endfunction

  // Helper function: Build a Read Transaction
  function transaction make_read(logic [6:0] addr);
    transaction t = new();
    t.op      = transaction::READ;
    t.wr_en   = 1'b0;
    t.rd_en   = 1'b1;
    t.rd_addr = addr;
    return t;
  endfunction

  pure virtual task run();
endclass

// ------------------------------------------------------------
// Test 1: Single Location Write-Read across 4 Blocks
// ------------------------------------------------------------
class write_read_single_test extends base_test;
  function new(mailbox #(transaction) wr_mbox, mailbox #(transaction) rd_mbox);
    super.new(wr_mbox, rd_mbox);
  endfunction

  task run();
    $display("\n[TEST] ---> Starting Write-Read Single Location Test <---");
    
    // Block 0 (addr 0x00)
    wr_mbox.put(make_write(7'h00, 8'hAA));
    rd_mbox.put(make_read(7'h00));

    // Block 1 (addr 0x20)
    wr_mbox.put(make_write(7'h20, 8'hBB));
    rd_mbox.put(make_read(7'h20));

    // Block 2 (addr 0x40)
    wr_mbox.put(make_write(7'h40, 8'hCC));
    rd_mbox.put(make_read(7'h40));

    // Block 3 (addr 0x60)
    wr_mbox.put(make_write(7'h60, 8'hDD));
    rd_mbox.put(make_read(7'h60));
  endtask
endclass

// ------------------------------------------------------------
// Test 2: Boundary Address Verification
// ------------------------------------------------------------
class boundary_test extends base_test;
  function new(mailbox #(transaction) wr_mbox, mailbox #(transaction) rd_mbox);
    super.new(wr_mbox, rd_mbox);
  endfunction

  task run();
    $display("\n[TEST] ---> Starting Boundary Address Test <---");
    
    // Block 0 Boundaries: 0x00 and 0x1F
    wr_mbox.put(make_write(7'h00, 8'h11)); rd_mbox.put(make_read(7'h00));
    wr_mbox.put(make_write(7'h1F, 8'h22)); rd_mbox.put(make_read(7'h1F));

    // Block 3 Boundaries: 0x60 and 0x7F
    wr_mbox.put(make_write(7'h60, 8'h33)); rd_mbox.put(make_read(7'h60));
    wr_mbox.put(make_write(7'h7F, 8'h44)); rd_mbox.put(make_read(7'h7F));
  endtask
endclass

// ------------------------------------------------------------
// Test 3: Block Isolation Test (Same offset, different blocks)
// ------------------------------------------------------------
class block_isolation_test extends base_test;
  function new(mailbox #(transaction) wr_mbox, mailbox #(transaction) rd_mbox);
    super.new(wr_mbox, rd_mbox);
  endfunction

  task run();
    $display("\n[TEST] ---> Starting Block Isolation Test <---");
    
    // Offset 0x05 in all 4 memory blocks
    wr_mbox.put(make_write(7'h05, 8'hA1)); // Block 0
    wr_mbox.put(make_write(7'h25, 8'hB2)); // Block 1
    wr_mbox.put(make_write(7'h45, 8'hC3)); // Block 2
    wr_mbox.put(make_write(7'h65, 8'hD4)); // Block 3

    rd_mbox.put(make_read(7'h05));
    rd_mbox.put(make_read(7'h25));
    rd_mbox.put(make_read(7'h45));
    rd_mbox.put(make_read(7'h65));
  endtask
endclass

// ------------------------------------------------------------
// Test 4: Directed Full Memory Sweep (128 Bytes)
// ------------------------------------------------------------
class full_mem_test extends base_test;
  function new(mailbox #(transaction) wr_mbox, mailbox #(transaction) rd_mbox);
    super.new(wr_mbox, rd_mbox);
  endfunction

  task run();
    $display("\n[TEST] ---> Starting Full Memory Write/Read Test <---");
    for (int i = 0; i < 128; i++) begin
      wr_mbox.put(make_write(i[6:0], i[7:0] ^ 8'hFF));
    end
    for (int i = 0; i < 128; i++) begin
      rd_mbox.put(make_read(i[6:0]));
    end
  endtask
endclass

// ------------------------------------------------------------
// Test 5: Randomized Stress Test
// ------------------------------------------------------------
class random_stress_test extends base_test;
  int num_txns;

  function new(mailbox #(transaction) wr_mbox, mailbox #(transaction) rd_mbox, int num_txns = 50);
    super.new(wr_mbox, rd_mbox);
    this.num_txns = num_txns;
  endfunction

  task run();
    transaction t;
    $display("\n[TEST] ---> Starting Random Stress Test (%0d Transactions) <---", num_txns);
    
    repeat (num_txns) begin
      t = new();
      if (!t.randomize() with { rst == 1'b1; wr_en != rd_en; }) 
        $fatal(1, "Randomization failed in stress test");
      
      if (t.wr_en)
        wr_mbox.put(t);
      else
        rd_mbox.put(t);
    end
  endtask
endclass

`endif
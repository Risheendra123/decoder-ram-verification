# Decoder RAM Verification Testbench (SystemVerilog)

A class-based SystemVerilog verification environment for a **128 x 8-bit decoder-based RAM**. The RAM is built from four 32-byte memory blocks selected by an address decoder. The testbench uses a layered architecture with drivers, monitors, a reference model and a scoreboard.

---

## Features

- Class-based layered testbench (transaction, drivers, monitors, reference model, scoreboard, environment)
- Interface with clocking blocks and modports for drivers and monitors
- Mailbox-based communication between components
- Self-checking: scoreboard compares DUT output against a reference model
- Directed tests plus a constrained-random stress test
- Waveform dump (`tb_top.vcd`) and a simulation watchdog timeout

---

## Design Under Test (DUT)

`decoder_ram` is a 128-byte memory split into 4 blocks of 32 bytes.

| Signal | Direction | Width | Description |
|---|---|---|---|
| `clk` | input | 1 | Clock |
| `rst` | input | 1 | Active-low asynchronous reset |
| `wr_en` | input | 1 | Write enable |
| `rd_en` | input | 1 | Read enable |
| `wr_addr` | input | 7 | Write address |
| `rd_addr` | input | 7 | Read address |
| `data_in` | input | 8 | Write data |
| `data_out` | output | 8 | Read data |
| `valid` | output | 1 | Read data valid |

**Address decoding**

- `addr[6:5]` selects the block (chip select): `00` = block 0, `01` = block 1, `10` = block 2, `11` = block 3
- `addr[4:0]` selects the word inside the block

---

## Testbench Architecture

```
            +-----------------------------------------------+
            |                  environment                  |
            |                                               |
  tests --> |  wr_driver --+                +-- wr_monitor  |
 (mailbox)  |              v                |       |       |
            |             [ interface ram_inf ] --> DUT     |
            |              ^                |       |       |
            |  rd_driver --+                +-- rd_monitor  |
            |                                   |     |     |
            |                                   v     v     |
            |                          ref_model --> scoreboard
            +-----------------------------------------------+
```

---

## File Structure

| File | Purpose |
|---|---|
| `module_decoder_ram.sv` | RTL of the DUT (`decoder_ram`) |
| `interface.sv` | `ram_inf` interface with clocking blocks and modports |
| `transaction.sv` | Transaction class (randomizable fields) |
| `done_txn.sv` | Helper class for done signalling |
| `generator.sv` | Random transaction generator |
| `write_driver.sv` | Drives write transactions onto the interface |
| `read_driver.sv` | Drives read transactions onto the interface |
| `write_monitor.sv` | Samples write activity and sends it to the scoreboard and reference model |
| `read_monitor.sv` | Samples read activity and sends it to the scoreboard and reference model |
| `ref_model.sv` | Golden memory model that predicts expected read data |
| `scoreboard.sv` | Compares actual vs expected and counts pass/fail |
| `Environment.sv` | Builds and starts all components |
| `test.sv` | Test classes (see below) |
| `tb_top.sv` | Top module: clock, DUT, reset, test sequencing, summary report |

---

## Test Cases

| Test | Description |
|---|---|
| `write_read_single_test` | Writes and reads one location in each of the 4 blocks |
| `boundary_test` | Checks boundary addresses (`0x00`, `0x1F`, `0x60`, `0x7F`) |
| `block_isolation_test` | Writes the same offset in all 4 blocks and checks they do not overwrite each other |
| `full_mem_test` | Writes then reads back all 128 locations |
| `random_stress_test` | Constrained-random reads and writes |

---





## Expected Output

At the end of simulation the testbench prints a summary:

```
==================================================
               VERIFICATION SUMMARY
  PASSED: <n>
  FAILED: <n>
==================================================
```
It also shows the output messages returned from tasks and functions(example build() in environment returns "ALL COMPONENTS BUILT") which are there in the files 
---

## Future Improvements

- Add functional coverage (covergroups for block, offset and operation)
- Add SystemVerilog assertions on the interface
- Convert to a UVM environment

---


## Author

**Budumuri Risheendra**  
GitHub: [@Risheendra123](https://github.com/Risheendra123)

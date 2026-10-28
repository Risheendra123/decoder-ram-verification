`ifndef TRANSACTION_SV
`define TRANSACTION_SV

class transaction;
typedef enum { WRITE,READ } op_t;
rand logic rst;
rand op_t op;
rand logic wr_en,rd_en;
rand logic [7:0] data_in ;
rand logic [6:0] wr_addr,rd_addr;
logic [7:0]data_out;
logic valid;

function new();
    op=WRITE;
    wr_addr=7'h00;
    rd_addr=7'h00;
    data_in=8'h00;
    data_out=8'h00;
    valid=1'b0;
endfunction

function void print (string tag="");
    $display("Time = %0t  | op = %s | wr_addr = %0h | rd_addr = %0h | data_in = %0h | data_out=%0h | valid = %0b",$time,op,wr_addr,rd_addr,data_in,data_out,valid);
    
endfunction
endclass

`endif
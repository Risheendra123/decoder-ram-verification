`ifndef GENERATOR_SV
`define GENERATOR_SV

`include "transaction.sv"
`include "done_txn.sv"
class generator;
   int transaction_number;
   done_txn done;
   transaction t_wrdriver;
   transaction t_rddriver;
   mailbox #(transaction) gen2wrdrv;
   mailbox #(transaction) gen2rddrv;
   mailbox #(done_txn) done_mbox;
   function new(mailbox #(transaction) gen_to_wdriver,mailbox #(transaction) gen_to_rdriver,int transaction_number);
      this.gen2wrdrv= gen_to_wdriver;
      this.gen2rddrv=gen_to_rdriver;
      this.transaction_number=transaction_number;
      //this.done_mbox=done_mbox;
      // t_wrdriver=new();
      // t_rddriver=new();
    endfunction
   
    //constraint c1{(wr_en && rd_en)!=1;}
    //constraint c2{rst dist{1'b1 :=transaction_number-5,1'b0 :=5};}


    task run(int transaction_number);
       begin
           for (int i =0 ;i<transaction_number ;i++ ) begin

              t_wrdriver=new();
              t_rddriver=new();
             

              assert(t_wrdriver.randomize()) else $fatal(1,"Randomization failed for write driver");
              assert(t_rddriver.randomize()) else $fatal(1,"Randomization failed for read driver");
              gen2wrdrv.put(t_wrdriver);
              gen2rddrv.put(t_rddriver);
              $display("Transaction passed to respective drivers: Transaction NO: %0d",transaction_number);
           end
       end
       
    endtask
endclass
`endif
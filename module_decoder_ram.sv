`ifndef MODULE_DECODER_RAM_SV
`define MODULE_DECODER_RAM_SV

module decoder_ram(
 input clk,rst,wr_en,rd_en,
 input [6:0]wr_addr,rd_addr,
 input [7:0] data_in,
 output reg [7:0] data_out,
 output reg valid
);
integer i;
wire [3:0] cs;
wire [4:0] word_address;
assign word_address= wr_addr[4:0];
assign cs[0]=(wr_addr[6:5]==2'b00);//cs=4'b0001
assign cs[1]=(wr_addr[6:5]==2'b01);//cs=4'b0010
assign cs[2]=(wr_addr[6:5]==2'b10);//cs=4'b0100
assign cs[3]=(wr_addr[6:5]==2'b11);//cs=4'b1000

reg [7:0] mem_block0[0:31];
reg [7:0] mem_block1[0:31];
reg [7:0] mem_block2[0:31];
reg [7:0] mem_block3[0:31];

//writing :

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        for (i =0 ;i<32; i++) begin
            mem_block0[i]=0;
            mem_block1[i]=0;
            mem_block2[i]=0;
            mem_block3[i]=0;
        end
    end
    else begin
        if (wr_en) begin
            case (cs)
               4'b0001 :  mem_block0[word_address] <= data_in;
               4'b0010 :  mem_block1[word_address] <= data_in;
               4'b0100 :  mem_block2[word_address] <= data_in;
               4'b1000 :  mem_block3[word_address] <= data_in;
                default: ;
            endcase
        end
    end
       
end

//Reading: 
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        data_out<=8'b0;
        valid <=0;
    end
    else begin
        if (rd_en) begin
            case (cs)
               4'b0001 : begin
                                   valid<=1;
                                   data_out <= mem_block0[word_address];
                            end
               4'b0010 :  begin
                                   valid<=1;
                                   data_out <= mem_block1[word_address];
                            end
               4'b0100 :  begin
                                   valid<=1;
                                   data_out <= mem_block2[word_address];
                            end
               4'b1000 :  begin
                                   valid<=1;
                                   data_out <= mem_block3[word_address];
                            end
                default: begin
                                   valid<=0;
                                   $display("Invalid address %0h",wr_addr);
                            end
            endcase
        end
    end
       
end
endmodule

`endif
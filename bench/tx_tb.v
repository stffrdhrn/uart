/* Test bench for the transmitter module 
 * Just reset and strobe a byte out on tx pin
 **/
module tx_tb();

reg       res_n, clk, stb;
reg [7:0] tx_byte;
wire      tx;

initial
begin
  tx_byte = 8'b0;
  res_n = 1'b1;
  stb = 1'b0;
  clk = 1'b0;
end

always
  #1 clk <= ~clk;
  
initial
begin
  #3 res_n = 1'b0;
  #3 res_n = 1'b1;
  
  #5 tx_byte = 8'b00101100;

  stb = 1'b1;
  #2 stb = 1'b0;
  
  
end
  
tx txi (
  .res_n(res_n),
  .tx(tx),
  .clk(clk),
  .tx_byte(tx_byte),
  .stb(stb)
);

endmodule

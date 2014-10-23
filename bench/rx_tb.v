/**
 * Testbench for receiver module
 * Simulates a 8n1 byte being revived
 */
module rx_tb();

reg             rx, res_n, clk;
wire    [7:0]   rx_byte;
wire            rdy;

initial 
begin
  rx = 1'b1;
  res_n = 1'b1;
  clk = 1'b0;
end

always
  #1 clk <= ~clk;
  
initial
begin
  #3 res_n = 1'b0;
  #3 res_n = 1'b1;
  
  #8 rx = 1'b0;      /* start bit */
  #8 rx = 1'b0;      /* 1 */
  #8 rx = 1'b0;      /* 2 */
  #8 rx = 1'b1;      /* 3 */
  #8 rx = 1'b1;      /* 4 */
  #8 rx = 1'b0;      /* 5 */
  #8 rx = 1'b0;      /* 6 */
  #8 rx = 1'b0;      /* 7 */
  #8 rx = 1'b1;      /* 8 */
  #8 rx = 1'b1;      /* end bit */
  
end
  
rx rxi (
  .res_n(res_n),
  .rx(rx),
  .clk(clk),
  .rx_byte(rx_byte),
  .rdy(rdy)
);

endmodule

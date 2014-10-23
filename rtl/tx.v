/* UART Transmitter module 
 * Transmits the bytes on tx_byte after stb signal goes high. 
 * Has asynchronous reset. 
 */ 
module tx (
  output          tx,
  input     [7:0] tx_byte,
  input           stb,   /* strobe tx_byte on posedge */
  input           res_n,
  input           clk    /* Baud Rate x 4 (same as rx) */ 
);

reg  [7:0] tx_byte_ff;    /* Clocked in byte to send out */
reg        stb_ff;        /* Indicator that the byte is ready to send */
reg  [2:0] bit_count;     /* Bit we are currently sending to TX when in SEND state */
reg  [1:0] baud_count, state, state_nxt;
reg        tx_ff;         /* The TX output register */

assign tx = tx_ff;

localparam WAIT = 3'b00,
           STRT = 3'b01,
           SEND = 3'b10,
           STOP = 3'b11;

/* Next state management */
always @(*)
begin
  case(state)
    WAIT:
      if (stb_ff)
        state_nxt = STRT; 
      else 
        state_nxt = WAIT;
    STRT:
      state_nxt = SEND;
    SEND:
      if (bit_count == 3'b111)
        state_nxt = STOP;
      else
        state_nxt = SEND;
    STOP:
      state_nxt = WAIT;
    default: state_nxt = WAIT;
  endcase
      
end

/* TX bits go out when the state changes */
always @(*)
case(state)
  STRT:    tx_ff = 1'b0;
  SEND:    tx_ff = tx_byte_ff[bit_count];
  STOP:    tx_ff = 1'b1;
  default: tx_ff = 1'b1;
endcase

/* Strobing in the tx_byte so we dont lose it */
always @(posedge clk or negedge res_n)
begin
  if (!res_n)
  begin
    tx_byte_ff <= 8'h00;
    stb_ff <= 1'b0;
  end
  else
  begin
    if ((state == WAIT) && !stb_ff) /* If we are waiting for the stb_ff and its not on turn it on*/
      stb_ff <= stb; 
    else if (state != WAIT) /* If we are done waiting we can turn off */ 
      stb_ff <= stb;
    else                    /* Otherwise maintain state */
      stb_ff <= stb_ff; 
      
    if (stb) /* strobe in the input on the stb signal */
      tx_byte_ff <= tx_byte;
    else 
      tx_byte_ff <= tx_byte_ff;

  end
end

/* Clock devider. We watch the 3rd bit of this counter
   to generate the baud rate clock 
 */
always @(posedge clk or negedge res_n)
begin
  if (!res_n)
    baud_count <= 2'h0;
  else
    baud_count <= baud_count + 1'b1;

end

/* State management block. Doing a few things here:
 *  - Do the state transition 
 *  - Keep track of the BIT count when we are in the SEND phase
 */
always @(posedge baud_count[1] or negedge res_n)
begin
  if (!res_n)
  begin
    bit_count <= 3'h0;
    state <= WAIT;
  end
  else
  begin
    state <= state_nxt;
    
   if (state == SEND)
     bit_count <= bit_count + 1'b1;
   else 
     bit_count <= 3'h0;
  end
end
    
endmodule
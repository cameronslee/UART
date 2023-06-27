`timescale 1ns/10ps
`include "Transmitter.v"
`include "Receiver.v"


module Uart ();
  parameter c_CLOCK_PERIOD_NS = 40;
  parameter c_CLKS_PER_BIT    = 217;
  parameter c_BIT_PERIOD      = 8600;
  
  reg r_Clock = 0;
  reg r_RX_DV = 0;
  wire w_TX_Active, w_UART_Line;
  wire w_TX_Serial;
  reg [7:0] r_TX_Byte = 0;
  wire [7:0] w_RX_Byte;

  wire o_unconnected;

  Receiver #(.clocks_per_bit(c_CLKS_PER_BIT)) Receiver_Inst 
    (.clk(r_Clock),
     .in(w_UART_Line),
     .out_data_valid(r_RX_DV),
     .out_data(w_RX_Byte)
     );
  
  Transmitter #(.clocks_per_bit(c_CLKS_PER_BIT)) Transmitter_Inst 
    (.clk(r_Clock),
     .data_valid(r_RX_DV),
     .in_data(r_TX_Byte),
     .active(w_TX_Active),
     .out_data(w_TX_Serial),
     .done(o_unconnected)
     );

  assign w_UART_Line = w_TX_Active ? w_TX_Serial : 1'b1;
  always #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;

  initial begin
    @(posedge r_Clock);
    @(posedge r_Clock);
    r_RX_DV = 1'b1;
    r_TX_Byte = 8'h3f;
    @(posedge r_Clock);
    r_RX_DV = 1'b0;

    @(posedge r_RX_DV);
    if(w_RX_Byte == 8'h3f) begin
      $display(r_TX_Byte);
      $display(w_RX_Byte);
      $display("Test Passed");
    end
    else
      $display("Test Failed");
    $finish();
  end
endmodule

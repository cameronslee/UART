module Receiver #(parameter clocks_per_bit = 217)
  (
    input clk, //UART internal clock
    input in, //input 
    output out_data_valid,
    output [7:0] out_data //data to output (1 byte)
  );

  //states
  parameter IDLE = 3'b000;
  parameter START_BIT = 3'b001;
  parameter DATA_BITS = 3'b010;
  parameter STOP_BIT = 3'b011;
  parameter CLEANUP = 3'b100;

  reg [7:0] clock_count = 0;
  reg [2:0] index = 0;
  reg [7:0] buffer = 0;
  reg dv = 0; //data valid
  reg [2:0] state = 0;

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        dv <= 1'b0;
        clock_count <= 0;
        index <= 0;
        if(in == 1'b0) //start bit detected (drops to low)
          state <= START_BIT;
      end
      START_BIT: begin
        if(clock_count == (clocks_per_bit-1)/2) begin //look for middle of bit
          if(in == 1'b0) begin //make sure its still low before we begin to read
            clock_count <= 0; //reset counter, at middle of the bit
            state <= DATA_BITS;
          end
          else 
            state <= IDLE; //not low, just go back to IDLE
        end
        else begin
          clock_count <= clock_count + 1;
        end
      end
      DATA_BITS: begin
        if(clock_count < clocks_per_bit-1) begin
          clock_count <= clock_count + 1;
        end
        else begin
          clock_count <= 0;
          buffer[index] <= in;
          //check if all data bits have been recvd
          if(index < 7) begin
            index <= index + 1;
          end
          else begin 
            index <= 0;
            state <= STOP_BIT;
          end
        end
      end
      STOP_BIT: begin
        if(clock_count < clocks_per_bit-1) begin //wait one cycle before ending
          clock_count <= clock_count + 1;
        end
        else begin
          dv <= 1'b1;
          clock_count <= 0;
          state <= CLEANUP;
        end
      end
      CLEANUP: begin
        state <= IDLE;
        dv <= 1'b0;
      end
      default: begin
        state <= IDLE;
      end
    endcase
  end
  assign out_data_valid = dv;
  assign out_data = buffer;
endmodule

module Transmitter #(parameter clocks_per_bit = 217)
  (
    input clk, //UART internal clock
    input data_valid,
    input [7:0] in_data,
    output reg active,
    output reg out_data,
    output reg done
  );

  //states
  localparam IDLE = 2'b00;
  localparam START_BIT = 2'b01;
  localparam DATA_BITS = 2'b10;
  localparam STOP_BIT = 2'b11;

  reg [1:0] state;
  reg [$clog2(clocks_per_bit):0] clock_count;
  reg [2:0] index = 0;
  reg [7:0] buffer = 0;

  always @(posedge clk) begin
    done <= 1'b0;
    case (state)
      IDLE: begin
        out_data <= 1'b1;
        clock_count <= 0;
        index <= 0;
        if(data_valid == 1'b1) begin
          active <= 1'b1;
          buffer <= in_data;
          state <= START_BIT;
        end
      end
      START_BIT: begin
        out_data <= 1'b0; //start bit = 0
        if(clock_count < clocks_per_bit-1) begin
          clock_count <= clock_count+1;
        end
        else begin
          clock_count <= 0;
          state <= DATA_BITS;
        end
      end
      DATA_BITS: begin
        out_data <= buffer[index];
        if(clock_count < clocks_per_bit-1) begin
          clock_count <= clock_count+1;
        end
        else begin
          clock_count <= 0;
          if (index < 7) begin
            index <= index + 1;
          end
          else begin 
            index <= 0;
            state <= STOP_BIT;
          end
        end
      end
      STOP_BIT: begin
        out_data <= 1'b1; //Stop bit = 1
        if(clock_count < clocks_per_bit-1) begin
          clock_count <= clock_count+1;
        end
        else begin
          done <= 1'b1;
          clock_count <= 0;
          state <= IDLE;
          active <= 1'b0;
        end
      end
      default: begin
        state <= IDLE;
      end
    endcase
  end
endmodule

`timescale 1ns / 1ps
// Moore FSM transfer engine: IDLE -> TRANSFER -> COMPLETE.
// Copies one 32-bit word per clock inside a 256 x 32 internal memory.
module dma_controller(
  input             clk,
  input             rst,
  input             start,
  input      [31:0] src_addr,
  input      [31:0] dst_addr,
  input      [31:0] length,
  output reg        busy,
  output reg        done,
  output reg        interrupt
);
  localparam IDLE = 2'b00, TRANSFER = 2'b01, COMPLETE = 2'b10;

  reg [1:0]  state;
  reg [31:0] src, dst, count;
  reg [31:0] memory [0:255];
  integer i;

  initial begin
    for (i = 0; i < 256; i = i + 1) memory[i] = 0;
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE; busy <= 0; done <= 0; interrupt <= 0;
    end else begin
      case (state)
        IDLE: begin
          done <= 0; interrupt <= 0;
          if (start && length != 0) begin
            busy <= 1; src <= src_addr; dst <= dst_addr;
            count <= length; state <= TRANSFER;
          end
        end
        TRANSFER: begin
          memory[dst] <= memory[src];
          src <= src + 1; dst <= dst + 1; count <= count - 1;
          if (count == 1) state <= COMPLETE;
        end
        COMPLETE: begin
          busy <= 0; done <= 1; interrupt <= 1; state <= IDLE;
        end
      endcase
    end
  end
endmodule

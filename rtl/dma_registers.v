`timescale 1ns / 1ps
// CPU-facing register file.
//   0x0 SRC_ADDR (R/W)   0x1 DST_ADDR (R/W)   0x2 LENGTH (R/W)
//   0x3 CONTROL  (W: bit0 = start, auto-clears, reads as 0)
//   0x4 STATUS   (R: bit1 = done, bit0 = busy)
module dma_registers(
  input             clk,
  input             rst,
  input      [3:0]  cpu_addr,
  input      [31:0] cpu_wdata,
  input             cpu_write,
  output reg [31:0] cpu_rdata,
  output reg        start,
  output reg [31:0] src_addr, dst_addr, length,
  input             busy,
  input             done
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      src_addr <= 0; dst_addr <= 0; length <= 0; start <= 0;
    end else begin
      start <= 0;                         // auto-clear: guarantees a 1-cycle pulse
      if (cpu_write) begin
        case (cpu_addr)
          4'h0: src_addr <= cpu_wdata;
          4'h1: dst_addr <= cpu_wdata;
          4'h2: length   <= cpu_wdata;
          4'h3: start    <= cpu_wdata[0];
        endcase
      end
    end
  end

  always @(*) begin
    case (cpu_addr)
      4'h0: cpu_rdata = src_addr;
      4'h1: cpu_rdata = dst_addr;
      4'h2: cpu_rdata = length;
      4'h4: cpu_rdata = {30'b0, done, busy};
      default: cpu_rdata = 32'b0;
    endcase
  end
endmodule

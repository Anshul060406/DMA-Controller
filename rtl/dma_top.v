`timescale 1ns / 1ps
// Structural wrapper: CPU register file + FSM transfer engine.
module dma_top(
  input         clk,
  input         rst,
  input  [3:0]  cpu_addr,
  input  [31:0] cpu_wdata,
  input         cpu_write,
  output [31:0] cpu_rdata,
  output        interrupt
);
  wire        start;
  wire [31:0] src_addr, dst_addr, length;
  wire        busy, done;

  dma_registers regs (
    .clk(clk), .rst(rst),
    .cpu_addr(cpu_addr), .cpu_wdata(cpu_wdata), .cpu_write(cpu_write),
    .cpu_rdata(cpu_rdata),
    .start(start), .src_addr(src_addr), .dst_addr(dst_addr), .length(length),
    .busy(busy), .done(done)
  );

  dma_controller ctrl (
    .clk(clk), .rst(rst), .start(start),
    .src_addr(src_addr), .dst_addr(dst_addr), .length(length),
    .busy(busy), .done(done), .interrupt(interrupt)
  );
endmodule

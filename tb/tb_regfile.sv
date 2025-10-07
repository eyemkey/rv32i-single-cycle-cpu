`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 03:41:13 PM
// Design Name: 
// Module Name: tb_regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_regfile;

  logic        clk, rst_n, write_enable;
  logic [4:0]  rs1_addr, rs2_addr, rd_addr;
  logic [31:0] rd_wdata;
  logic [31:0] rs1_rdata, rs2_rdata;

  // DUT
  regfile dut (
    .clk(clk),
    .rst_n(rst_n),
    .write_enable(write_enable),   // or .we(write_enable) if your port is 'we'
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .rd_wdata(rd_wdata),
    .rs1_rdata(rs1_rdata),
    .rs2_rdata(rs2_rdata)
  );

  // 100 MHz clock
  initial clk = 0;
  always  #5 clk = ~clk;

  // ---------- Helper tasks ----------

  // Safe write: drive on negedge, capture on next posedge
  task automatic write_reg(input [4:0] r, input [31:0] val);
    write_enable = 1'b1;
    rd_addr      = r;
    rd_wdata     = val;
    @(posedge clk); #1;         // write happens here
    write_enable = 1'b0;
  endtask

  // Robust read: set addresses on negedge, sample after posedge
  // (works for both comb-read and sync-read implementations)
  task automatic read_regs(input [4:0] a, input [4:0] b,
                           input [31:0] exp_a, input [31:0] exp_b);
    rs1_addr = a;
    rs2_addr = b;
    @(posedge clk);  // allow a registered read to update
    @(negedge clk); 
    assert (rs1_rdata === exp_a) else $fatal(1, "rs1 mismatch: exp=%h got=%h (addr=%0d)", exp_a, rs1_rdata, a);
    assert (rs2_rdata === exp_b) else $fatal(1, "rs2 mismatch: exp=%h got=%h (addr=%0d)", exp_b, rs2_rdata, b);
  endtask

  // ---------- Test sequence ----------
  initial begin
    rst_n = 0; write_enable = 0; 
    rs1_addr = 0; rs2_addr = 0; rd_addr = 0; rd_wdata = 0;
    @(negedge clk); 
    rst_n = 1; 
    #1; 
    write_reg(5'd0, 32'habcdef00); 
    read_regs(5'd0, 5'd0, 32'h0, 32'h0); 
    
    @(negedge clk); 
    write_reg(5'd5, 32'h11111111); 
    write_reg(5'd6, 32'h22222222); 
    read_regs(5'd5, 5'd6, 32'h11111111, 32'h22222222); 
    
    @(negedge clk); 
    rs1_addr = 5'd7; 
    rs2_addr = 5'd8; 
    write_enable = 1; 
    rd_addr = 5'd7; 
    rd_wdata = 32'hA5A5A5A5; 
    
    @(posedge clk); 
    #1; 
    write_enable = 0;  
    
    assert(rs1_rdata == 32'hA5A5A5A5) else $fatal(1, "RAW failed on rs1"); 
    assert(rs2_rdata == 32'h0) else $fatal(1, "unexpected rs2"); 
    
    $display("regfile tests passed");
    $finish;
  end

endmodule
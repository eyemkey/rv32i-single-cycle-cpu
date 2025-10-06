`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 03:32:08 PM
// Design Name: 
// Module Name: regfile
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


module regfile(
        input wire clk, 
        input wire rst_n, //reset when 0
        input wire write_enable, 
        
        input wire [31:0] rd_wdata, 
        input wire [4:0] rs1_addr, 
        input wire [4:0] rs2_addr, 
        input wire [4:0] rd_addr,
        input wire RegWrite,
        output wire [31:0] rs1_rdata, 
        output wire [31:0] rs2_rdata 
    );
    
    
    reg [31:0] regs [31:0]; 
    
    integer i; 
    always @(posedge clk) begin
        if(!rst_n) begin //reset logic
            for(i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0;
            end
        end else if (write_enable && (rd_addr != 5'd0)) begin //no writing into r0
            regs[rd_addr] = rd_wdata;
        end
    end
    
    assign rs1_rdata = (rs1_addr == 5'd0) ? 32'b0 : regs[rs1_addr]; 
    assign rs2_rdata = (rs2_addr == 5'd0) ? 32'b0 : regs[rs2_addr]; 
    
endmodule

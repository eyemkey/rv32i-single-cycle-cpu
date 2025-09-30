`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 04:33:20 PM
// Design Name: 
// Module Name: pc
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


module pc
    #(parameter RESET_ADDR = 0)
    (
        input wire clk, 
        input wire rst_n, 
        input wire [31:0] next_pc, 
        output reg [31:0] pc
    );
    
    
    always @(posedge clk) begin
        if(!rst_n) begin
            pc <= RESET_ADDR;
        end
        else begin
            pc <= next_pc;  
        end             
    end
endmodule
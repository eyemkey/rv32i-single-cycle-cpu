`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 04:37:02 PM
// Design Name: 
// Module Name: dmem
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


module dmem
    #(parameter DEPTH_WORDS = 1024)
    (
        input wire clk, 
        input wire rst_n, 
        
        input wire mem_read,    // signal for reading
        input wire mem_write,   // signal for writing
        input wire [31:0] addr, 
        input wire [31:0] wdata, //write data 
        output wire [31:0] rdata // read data
    );
    
    
    reg [31:0] mem [DEPTH_WORDS-1:0];
    wire [31:2] widx = addr[31:2]; // addr / 4
    
    wire valid_access = (widx < DEPTH_WORDS);
    assign rdata = (mem_read && valid_access) ? mem[widx] : 32'b0; 
    
    always @(posedge clk) begin
        if(mem_write && valid_access) begin
            mem[widx] <= wdata; 
        end 
    end
    
endmodule

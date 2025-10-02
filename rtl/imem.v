`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2025 09:36:28 PM
// Design Name: 
// Module Name: imem
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


module imem(
        input wire [31:0] pc,
        output wire [31:0] instr
    );
    
    reg [31:0] instructions [255:0];
    
    assign instr = instructions[ pc[31:2] ]; //pc[31:2] == pc >> 2;
endmodule

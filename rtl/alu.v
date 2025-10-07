`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 08:13:13 PM
// Design Name: 
// Module Name: alu
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


module alu(
        input wire [31:0] a, 
        input wire [31:0] b, 
        input wire [3:0] op, 
        output reg [31:0] y, 
        output zero
    );
    
    localparam [3:0]
        ALU_ADD  = 4'd0,
        ALU_SUB  = 4'd1,
        ALU_AND  = 4'd2,
        ALU_OR   = 4'd3,
        ALU_XOR  = 4'd4, 
        ALU_SLL  = 4'd5, 
        ALU_SRL  = 4'd6,
        ALU_SRA  = 4'd7, 
        ALU_SLT  = 4'd8, 
        ALU_SLTU = 4'd9;
     
    
    wire [4:0] shift_amount = b[4:0]; 
    wire signed [31:0] a_s = a; 
    wire signed [31:0] b_s = b; 
    
    always @(*) begin
        case(op)
            ALU_ADD :  y = a + b;
            ALU_SUB :  y = a - b;
            ALU_AND :  y = a & b;
            ALU_OR  :  y = a | b;
            ALU_XOR :  y = a ^ b;
            ALU_SLL :  y = a << shift_amount;
            ALU_SRL :  y = a >> shift_amount;
            ALU_SRA :  y = a_s >>> shift_amount;          // arithmetic right
            ALU_SLT :  y = (a_s < b_s) ? {{(31){1'b0}},1'b1} : {32{1'b0}};
            ALU_SLTU: y = (a   < b  ) ? {{(31){1'b0}},1'b1} : {32{1'b0}};
            default :  y = {32{1'b0}};
        endcase
    end
    
    assign zero = (y == 32'h00000000);
      
endmodule

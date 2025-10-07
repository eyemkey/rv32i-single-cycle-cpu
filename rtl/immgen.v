`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 10:25:10 PM
// Design Name: 
// Module Name: immgen
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


module immgen(
        input wire [31:0] instr, 
        output wire [31:0] imm_out
    );
    
    localparam [6:0]
        I_TYPE_OPCODE = 7'b0010011, 
        S_TYPE_OPCODE = 7'b0100011,
        LW_OPCODE = 7'b0000011, 
        JALR_OPCODE = 7'b1100111; 
    
    reg [31:0] imm_out_r; 
    
    always @(*) begin
        case(instr[6:0])
            I_TYPE_OPCODE, 
            LW_OPCODE,
            JALR_OPCODE: imm_out_r = { {20{instr[31]}}, instr[31:20] };
            
            S_TYPE_OPCODE: imm_out_r = { {20{instr[31]}}, instr[31:25] , instr[11:7]};
            
            default: imm_out_r = 32'b0;
        endcase
    end
    
    assign imm_out = imm_out_r; 
endmodule

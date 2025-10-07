`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 09:49:54 PM
// Design Name: 
// Module Name: cpu_core
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


module cpu_core(
        input wire clk, 
        input wire rst_n
    );
    
    wire [31:0] pc_cur; 
    wire [31:0] pc_plus4 = pc_cur + 32'd4; 
    wire [31:0] pc_next = pc_plus4; 
    
    pc u_pc(
        .clk(clk), 
        .rst_n(rst_n), 
        .next_pc(pc_next), 
        .pc(pc_cur)
    );
    
    
    wire [31:0] instr; 
    imem u_imem(
        .pc(pc_cur), 
        .instr(instr)
    ); 
    
    
    wire [4:0] rd, rs1, rs2; 
    wire [2:0] funct3; 
    wire [6:0] funct7; 
    wire RegWrite; 
    wire [3:0] ALUOp; 
    wire illegal; 
    wire alu_src_ctrl; 
    
    decoder u_decoder(
        .instr(instr), 
        .rs1(rs1), 
        .rs2(rs2),  
        .rd(rd), 
        .funct3(funct3), 
        .funct7(funct7), 
        .RegWrite(RegWrite), 
        .ALUOp(ALUOp), 
        .alu_src_ctrl(alu_src_ctrl), 
        .illegal(illegal)
    ); 
    
    
    wire [31:0] rd_data; 
    wire [31:0] rs1_data, rs2_data;
    wire we; 
    
    regfile u_regfile(
        .clk(clk), 
        .rst_n(rst_n), 
        .write_enable(RegWrite), 
        .rd_wdata(rd_data), 
        .rs1_addr(rs1), 
        .rs2_addr(rs2), 
        .rd_addr(rd), 
        .rs1_rdata(rs1_data), 
        .rs2_rdata(rs2_data)
    );
    
    wire [31:0] imm_out; 
    immgen u_immgen(
        .instr(instr), 
        .imm_out(imm_out)
    ); 
    
    wire [31:0] alu_src_2; 
    reg [31:0] alu_src_2_r; 
    
    always @(*) begin
        if(alu_src_ctrl == 1'b0) begin
            alu_src_2_r = rs2_data; 
        end else begin
            alu_src_2_r = imm_out;  
        end
    end
    
    assign alu_src_2 = alu_src_2_r; 
    
    wire zero; 
    alu u_alu(
        .a(rs1_data), 
        .b(alu_src_2), 
        .op(ALUOp), 
        .y(rd_data), 
        .zero(zero)
    ); 
    
        
endmodule

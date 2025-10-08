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
    
    wire [31:0] instr; 
    
    wire [4:0]  rd_addr, rs1_addr, rs2_addr; 
    wire [2:0]  funct3; 
    wire [6:0]  funct7; 
    wire        RegWrite; 
    wire [3:0]  ALUOp;
    wire        alu_src_ctrl; 
    wire        mem_read;
    wire        mem_write; 
    wire        mem_to_reg; 
    wire        illegal;
    
    
    wire [31:0] wb_mux_result; 
    wire [31:0] rs1_data; 
    wire [31:0] rs2_data; 
    
    wire [31:0] imm_out; 
    
    wire [31:0] rdata;
    
    wire [31:0] alu_src_1; 
    wire [31:0] alu_src_2; 
    wire [31:0] alu_res;
    wire        zero; 
    
    pc u_pc(
        .clk(clk), 
        .rst_n(rst_n), 
        .next_pc(pc_next), 
        .pc(pc_cur)
    );
    
    imem u_imem(
        .pc(pc_cur), 
        .instr(instr)
    );
    
    decoder u_decoder(
        .instr(instr), 
        .rs1(rs1_addr), 
        .rs2(rs2_addr),  
        .rd(rd_addr), 
        .funct3(funct3), 
        .funct7(funct7), 
        .RegWrite(RegWrite), 
        .ALUOp(ALUOp), 
        .alu_src_ctrl(alu_src_ctrl), 
        .mem_read(mem_read), 
        .mem_write(mem_write), 
        .mem_to_reg(mem_to_reg),
        .illegal(illegal)
    );
    
    assign wb_mux_result = mem_to_reg ? rdata : alu_res;
    
    regfile u_regfile(
        .clk(clk), 
        .rst_n(rst_n), 
        .write_enable(RegWrite), 
        .rd_wdata(wb_mux_result), 
        .rs1_addr(rs1_addr), 
        .rs2_addr(rs2_addr), 
        .rd_addr(rd_addr), 
        .rs1_rdata(rs1_data), 
        .rs2_rdata(rs2_data)
    );
    
    
    immgen u_immgen(
        .instr(instr), 
        .imm_out(imm_out)
    ); 
    
    dmem u_dmem(
        .clk(clk), 
        .rst_n(rst_n), 
        .mem_read(mem_read), 
        .mem_write(mem_write), 
        .addr(alu_res), 
        .wdata(rs2_data), 
        .rdata(rdata)
    ); 
    
    assign alu_src_1 = rs1_data; 
    assign alu_src_2 = (alu_src_ctrl) ? imm_out : rs2_data;
    
    alu u_alu(
        .a(alu_src_1), 
        .b(alu_src_2), 
        .op(ALUOp), 
        .y(alu_res), 
        .zero(zero)
    ); 
    
        
endmodule

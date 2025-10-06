`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 03:03:32 PM
// Design Name: 
// Module Name: tb_decoder
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


module tb_decoder(); 

    logic [31:0] instr; 
    logic [4:0] rs1, rs2, rd; 
    logic [2:0] funct3; 
    logic [6:0] funct7; 
    logic       RegWrite, illegal; 
    logic [3:0] ALUOp; 
    
    decoder dut(
        .instr(instr), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd), 
        .funct3(funct3), 
        .funct7(funct7), 
        .RegWrite(RegWrite), 
        .ALUOp(ALUOp), 
        .illegal(illegal)
    ); 
    
    wire [6:0] R_TYPE_OPCODE = 7'b0110011;
    
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
        ALU_SLTU = 4'd9,
        ALU_INV  = 4'd15;

    function automatic [31:0] rtype( //creates r_type instructions
        input [6:0] f7, input [4:0] rs2_i, input [4:0] rs1_i, 
        input [2:0] f3, input [4:0] rd_i
    );
        rtype = {f7, rs2_i, rs1_i, f3, rd_i, R_TYPE_OPCODE};
    endfunction

    //Check Test
    task automatic check(
        input [31:0] instr_i, 
        input [3:0] exp_ALUOp, 
        input exp_illegal, 
        input exp_RegWrite, 
        input [4:0] exp_rd, 
        input [4:0] exp_rs1, 
        input [4:0] exp_rs2
    ); begin
        
        assert(rd == exp_rd) else $fatal(1, "rd mismatch: got %0d exp %0d, rd, exp_rd"); 
        assert(rs1 == exp_rs1) else $fatal(1, "rs1 mismatch: got %0d exp %0d, rs1, exp_rs1"); 
        assert(rs2 == exp_rs2) else $fatal(1, "rs2 mismatch: got %0d exp %0d, rs2, exp_rs2"); 
        
        assert(ALUOp == exp_ALUOp) else $fatal(1, "ALUOp mismatch: got $0d exp $0d, ALUOp, exp_ALUOp"); 
        assert(illegal == exp_illegal) else $fatal(1, "illegal mismatch: got %0b exp %0b, illegal, exp_illegal"); 
        assert(RegWrite == exp_RegWrite) else $fatal(1, "RegWrite mismatch: got %0b exp %0b, RegWrite, exp_RegWrite"); 
        
        $display("OK: instr=%0x%08h | rd=%0d | rs1=%0d | rs2=%0d | ALUOp=%0d | illegal=%0b | RegWrite=%0b", 
                    instr, rd, rs1, rs2, ALUOp, illegal, RegWrite); 
    
    end
    endtask
    
    
    //Test Sequence
    initial begin
        $display("Starting tb_decoder...");
        
        //ADD rd=5, rs1=6, rs2=7
        check(rtype(7'b0000000, 5'd7, 5'd6, 3'b000, 5'd5),
            ALU_ADD, /*illegal*/0, /*RegWrite*/1, /*exp_rd*/ 5'd5, /*exp_rs1*/ 5'd6, /*exp_rs2*/ 5'd7);
    
        // SUB  rd=8, rs1=9, rs2=10
        check(rtype(7'b0100000, 5'd10, 5'd9, 3'b000, 5'd8),
            ALU_SUB, 0, 1, 5'd8, 5'd9, 5'd10);
    
        // SLL
        check(rtype(7'b0000000, 5'd3, 5'd2, 3'b001, 5'd1),
            ALU_SLL, 0, 1, 5'd1, 5'd2, 5'd3);
    
        // SLT
        check(rtype(7'b0000000, 5'd4, 5'd3, 3'b010, 5'd2),
            ALU_SLT, 0, 1, 5'd2, 5'd3, 5'd4);
    
        // SLTU
        check(rtype(7'b0000000, 5'd4, 5'd3, 3'b011, 5'd2),
            ALU_SLTU, 0, 1, 5'd2, 5'd3, 5'd4);
    
        // XOR
        check(rtype(7'b0000000, 5'd14, 5'd13, 3'b100, 5'd12),
            ALU_XOR, 0, 1, 5'd12, 5'd13, 5'd14);
    
        // SRL
        check(rtype(7'b0000000, 5'd6, 5'd5, 3'b101, 5'd4),
            ALU_SRL, 0, 1, 5'd4, 5'd5, 5'd6);
    
        // SRA
        check(rtype(7'b0100000, 5'd6, 5'd5, 3'b101, 5'd4),
            ALU_SRA, 0, 1, 5'd4, 5'd5, 5'd6);
    
        // OR
        check(rtype(7'b0000000, 5'd21, 5'd20, 3'b110, 5'd22),
            ALU_OR, 0, 1, 5'd22, 5'd20, 5'd21);
    
        // AND
        check(rtype(7'b0000000, 5'd1, 5'd2, 3'b111, 5'd3),
            ALU_AND, 0, 1, 5'd3, 5'd2, 5'd1);
              
         // ---- Illegal combo (wrong funct7 for SLL) ----
        check(rtype(7'b0100000, 5'd3, 5'd2, 3'b001, 5'd1),
            ALU_INV, /*illegal*/1, /*RegWrite for R-type in your design*/1, 5'd1, 5'd2, 5'd3);
                
        // ---- Non R-type opcode (ADDI) -> should be illegal & no RegWrite per your decoder ----
        // (when opcode != 0110011, it leaves defaults)
        check(itype_addi(12'sd7, 5'd2, 5'd1),
            ALU_INV, /*illegal*/1, /*RegWrite*/0, 5'd1, 5'd2, /*rs2 undefined*/5'd0);
            
        $display ("All decoder tests passed!."); 
        $finish;     
    end
    

endmodule

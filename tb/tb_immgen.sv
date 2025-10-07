`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 03:38:29 PM
// Design Name: 
// Module Name: tb_immgen
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


module tb_immgen();
    
    logic [31:0] instr; 
    wire [31:0] imm_out; 
    
    
    immgen dut(
        .instr(instr), 
        .imm_out(imm_out)    
    ); 
    
    localparam [6:0]
        R_ARIT_OPCODE = 7'b0110011,
        I_ARIT_OPCODE = 7'b0010011;
    
    function automatic [31:0] enc_i(input int imm12, 
        input logic [4:0] rs1, 
        input logic [2:0] funct3, 
        input logic [4:0] rd, 
        input logic [6:0] opcode);
        logic [11:0] imm12_u = imm12[11:0]; 
        enc_i = {imm12_u, rs1, funct3, rd, opcode};
    endfunction                             
    
    task automatic check_i(string name, int imm12, logic [6:0] opcode); 
        int signed s12 = imm12 <<< 20 >>> 20; 
        instr = enc_i(imm12, 5'd3, 3'b000, 5'd1, opcode); 
        #1; 
        assert(imm_out === s12)
            else $fatal(1, "[%s] imm=%0d got=%h", name, s12, imm_out);    
    endtask 
   
   
    initial begin
        check_i("I-ARITH zero", 12'sd0, I_ARIT_OPCODE); 
        check_i("I-ARITH +2047",    12'sd2047,  I_ARIT_OPCODE);
        check_i("I-ARITH -2048",    -12'sd2048, I_ARIT_OPCODE); 
        
        foreach (instr[i]) begin end
        for(int i = 0; i < 20; i++) begin
            int r = $urandom_range(-2048, 2047); 
            check_i($sformatf("RAND %0d", i), r, I_ARIT_OPCODE);
        end
        
        
        instr = {12'hABC, 5'd2, 3'b000, 5'd1, R_ARIT_OPCODE};
        #1;
        assert (imm_out === 32'h0)
          else $fatal(1, "[R-type default] expected 0, got %h", imm_out);
    
        $display("imm_gen: all tests passed");
        $finish;   
    end        
endmodule

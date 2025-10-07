`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 09:27:32 PM
// Design Name: 
// Module Name: tb_alu
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


module tb_alu();

    localparam int ALU_ADD  = 4'd0;
    localparam int ALU_SUB  = 4'd1;
    localparam int ALU_AND  = 4'd2;
    localparam int ALU_OR   = 4'd3;
    localparam int ALU_XOR  = 4'd4;
    localparam int ALU_SLL  = 4'd5;
    localparam int ALU_SRL  = 4'd6;
    localparam int ALU_SRA  = 4'd7;
    localparam int ALU_SLT  = 4'd8;
    localparam int ALU_SLTU = 4'd9;
    
    logic [31:0] a, b, y; 
    logic [3:0] op; 
    logic zero; 
    
    
    alu dut(
        .a(a), 
        .b(b), 
        .op(op), 
        .y(y), 
        .zero(zero)
    ); 
    
    int unsigned errors = 0; 
    
    function automatic logic [31:0] model_alu(  input logic [31:0] a_i, 
                                                input logic [31:0] b_i, 
                                                input logic [3:0] op_i);
        logic [31:0] res; 
        logic signed [31:0] as = a_i; 
        logic signed [31:0] bs = b_i; 
        logic [4:0] shamt = b_i[4:0]; 
        
        unique case (op_i)
            ALU_ADD :  res = a_i + b_i;
            ALU_SUB :  res = a_i - b_i;
            ALU_AND :  res = a_i & b_i;
            ALU_OR  :  res = a_i | b_i;
            ALU_XOR :  res = a_i ^ b_i;
            ALU_SLL :  res = a_i << shamt;
            ALU_SRL :  res = a_i >> shamt;
            ALU_SRA :  res = as  >>> shamt;           // arithmetic right
            ALU_SLT :  res = (as < bs) ? 32'd1 : 32'd0;
            ALU_SLTU:  res = ($unsigned(a_i) < $unsigned(b_i)) ? 32'd1 : 32'd0;
            default :  res = '0;
        endcase          
        
        return res;                
    endfunction
    
    task automatic check(input string name); 
        logic [31:0] exp = model_alu(a, b, op); 
        #2; 
        if (y !== exp) begin
            $error("[%s] MISMATCH: op=%0d a=%h got=%h exp=%h", 
                    name, op, a, b, y, exp); 
            errors++;            
        end
        
        if(zero !== (exp == 32'h0000_0000)) begin
            $error("[%s] ZERO FLAG WRONG: op=%0d a=%h b=%h  y=%h zero=%0b exp_zero=%0b",
             name, op, a, b, y, zero, (exp==0));
            errors++;  
        end
    endtask 
    
    
    int N;
    
    initial begin
        // ---------- Directed tests ----------
        // Basic add/sub
        a=32'd5;          b=32'd7;         op=ALU_ADD;  check("ADD 5+7");
        a=32'hFFFF_FFFD;  b=32'd5;         op=ALU_ADD;  check("ADD -3+5");
        a=32'd5;          b=32'd7;         op=ALU_SUB;  check("SUB 5-7");
        a=32'h8000_0000;  b=32'd1;         op=ALU_SRA;  check("SRA sign-prop");
        a=32'h8000_0000;  b=32'd1;         op=ALU_SRL;  check("SRL zero-fill");
        a=32'h0000_0003;  b=32'd5;         op=ALU_SLL;  check("SLL");
        a=32'hF0F0_0000;  b=32'h0FF0_FFFF; op=ALU_OR;   check("OR");
        a=32'hF0F0_00F0;  b=32'h0FF0_0FF0; op=ALU_AND;  check("AND");
        a=32'hAAAA_AAAA;  b=32'h5555_5555; op=ALU_XOR;  check("XOR");
    
        // SLT/SLTU boundaries
        a=32'hFFFF_FFFF;  b=32'h0000_0001; op=ALU_SLT;  check("SLT -1 < 1");
        a=32'hFFFF_FFFF;  b=32'h0000_0001; op=ALU_SLTU; check("SLTU 0xFFFF_FFFF <u 1 ?");
        a=32'h8000_0000;  b=32'h7FFF_FFFF; op=ALU_SLT;  check("SLT INT_MIN < INT_MAX");
        a=32'h7FFF_FFFF;  b=32'h8000_0000; op=ALU_SLT;  check("SLT INT_MAX < INT_MIN");
        a=32'h0000_0000;  b=32'h0000_0000; op=ALU_SUB;  check("ZERO flag");
    
        // Shifts with large amounts (mod-32 behavior)
        a=32'h0000_0001;  b=32'd33;        op=ALU_SLL;  check("SLL shamt 33 -> 1");
        a=32'h8000_0000;  b=32'd33;        op=ALU_SRA;  check("SRA shamt 33 -> 1");
    
        // ---------- Randomized tests ----------
        N = 0; // bump if you want more
        for (int i = 0; i < N; i++) begin
          a  = $urandom();
          b  = $urandom();
          op = $urandom_range(ALU_ADD, ALU_SLTU);
          check($sformatf("RND[%0d]", i));
        end
    
        // ---------- Summary ----------
        if (errors == 0) begin
          $display("\nALU tests PASSED (directed + %0d random).\n", N);
        end else begin
          $display("\n ALU tests FAILED with %0d error(s).\n", errors);
        end
        $finish;
    end
endmodule

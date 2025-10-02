`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2025 10:20:35 PM
// Design Name: 
// Module Name: tb_imem
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


module tb_imem();

    logic [31:0] pc; 
    logic [31:0] instr; 
    
    imem dut(
        .pc(pc), 
        .instr(instr)
    );

    initial begin
        for(int i = 0; i < 4; i++) begin
            dut.instructions[i] = i * 32'h11111111;
        end
    end
    
    initial begin 
    
        for(int i = 0; i < 4; i++) begin
            pc = i * 4; 
            #1;
            
            assert(instr == i * 32'h11111111)
                else $fatal("Mismatch at PC=$0d: got %h, expected %h",
                              pc, instr, i * 32'h11111111);        
        end
        $display("All IMEM tests have passed!"); 
        $finish;
    end
    
    initial begin
        $monitor("T=%0t | PC=%0d | instr=%h", $time, pc, instr); 
    end
endmodule

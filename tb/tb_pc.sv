`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 04:40:34 PM
// Design Name: 
// Module Name: tb_pc
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


module tb_pc();
    
    logic clk; 
    logic rst_n; 
    logic [31:0] next_pc; 
    logic [31:0] pc = 32'h00000000; 
    
    pc #(.RESET_ADDR(32'h00000000)) dut (
        .clk(clk), 
        .rst_n(rst_n), 
        .next_pc(next_pc), 
        .pc(pc)
    ); 

    always #5 clk = ~clk; 
    
    initial begin
        clk = 0; 
        rst_n = 0; 
        next_pc = 32'h0000_0000; 
        
        
        #20; 
        rst_n = 1; 
        
        #10 next_pc = 32'h0000_0004; 
        #10 next_pc = 32'h0000_0008; 
        #10 next_pc = 32'h0000_000C; 
        
        #10 rst_n = 0; 
        #10 rst_n = 1; 
        
        #10 next_pc = 32'h0000_00010; 
        #10 next_pc = 32'h0000_00014;
        
        #50 $finish; 
    end
    
    logic [31:0] prev_next_pc = 32'h00000000; 
    
    always @(posedge clk) begin
        if(!rst_n) begin
            assert (pc == prev_next_pc)
                else $error("Reset failed: pc=%h at time %0t", pc, $time);
            prev_next_pc <= 32'h00000000;
        end
        else begin
            assert (pc == prev_next_pc)
                else $error("PC did not update correctly: pc=%h next_pc=%h time=%0t", pc, next_pc, $time); 
            prev_next_pc <= next_pc;
        end
    end
    
    
    initial begin
        $monitor("T=%0t | rst_n=%b | next_pc=%h | pc=%h", 
                $time, rst_n, next_pc, pc);
    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2025 01:46:40 PM
// Design Name: 
// Module Name: decoder
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


module decoder(
    input  wire [31:0] instr, 
    output wire [4:0]  rs1, 
    output wire [4:0]  rs2, 
    output wire [4:0]  rd, 
    output wire [2:0]  funct3, 
    output wire [6:0]  funct7, 
    output wire        RegWrite, 
    output wire [3:0]  ALUOp, 
    output wire        alu_src_ctrl, 
    output wire        illegal
);

    // --- Field extraction ---
    wire [6:0] opcode = instr[6:0];        // 7-bit
    assign rd     = instr[11:7];           // 5-bit
    assign funct3 = instr[14:12];          // 3-bit
    assign rs1    = instr[19:15];          // 5-bit
    assign rs2    = instr[24:20];          // 5-bit
    assign funct7 = instr[31:25];          // 7-bit

    // --- Encodings ---
    localparam [6:0] 
        R_TYPE_OPCODE = 7'b0110011, 
        I_TYPE_OPCODE = 7'bb0010011,
        LOAD_OPCODE = 7'b0000011,
        JALR_OPCODE = 7'b1100111; 
        

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

    reg        reg_write_r; 
    reg [3:0]  alu_ctrl_r; 
    reg        illegal_r; 
    reg        alu_src_r; 
    
    always @* begin
        // Safe defaults
        reg_write_r = 1'b0; 
        alu_ctrl_r  = ALU_INV; 
        illegal_r   = 1'b1; 

        case (opcode)
            R_TYPE_OPCODE: begin
                reg_write_r = 1'b1; // R-type writes rd
                alu_src_r = 1'b0; 
                case (funct3)
                    3'b000: begin // ADD / SUB
                        if      (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_ADD;  illegal_r = 1'b0; end
                        else if (funct7 == 7'b0100000) begin alu_ctrl_r = ALU_SUB;  illegal_r = 1'b0; end
                    end         
                    3'b001: begin // SLL
                        if (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_SLL;  illegal_r = 1'b0; end 
                    end
                    3'b010: begin // SLT
                        if (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_SLT;  illegal_r = 1'b0; end
                    end
                    3'b011: begin // SLTU
                        if (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_SLTU; illegal_r = 1'b0; end
                    end
                    3'b100: begin // XOR
                        if (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_XOR;  illegal_r = 1'b0; end 
                    end
                    3'b101: begin // SRL / SRA
                        if      (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_SRL;  illegal_r = 1'b0; end 
                        else if (funct7 == 7'b0100000) begin alu_ctrl_r = ALU_SRA;  illegal_r = 1'b0; end
                    end
                    3'b110: begin // OR
                        if (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_OR;   illegal_r = 1'b0; end
                    end
                    3'b111: begin // AND
                        if (funct7 == 7'b0000000) begin alu_ctrl_r = ALU_AND;  illegal_r = 1'b0; end
                    end
                    default: ; // keep invalid
                endcase
            end
            
            I_TYPE_OPCODE: begin
                reg_write_r = 1'b1; 
                alu_src_r = 1'b1;
                case(funct3)
                    3'b000: begin alu_ctrl_r = ALU_ADD; illegal_r = 1'b0; end
                    3'b010: begin alu_ctrl_r = ALU_SLT; illegal_r = 1'b0; end
                    3'b011: begin alu_ctrl_r = ALU_SLTU; illegal_r = 1'b0; end
                    3'b100: begin alu_ctrl_r = ALU_XOR; illegal_r = 1'b0; end
                    3'b110: begin alu_ctrl_r = ALU_OR; illegal_r = 1'b0; end
                    3'b111: begin alu_ctrl_r = ALU_AND; illegal_r = 1'b0; end
                    
                    3'b001: begin
                        if(instr[31:25] == 7'b0000000) alu_ctrl_r = ALU_SLL; 
                        else illegal_r = 1'b1;
                    end
                    
                    3'b101: begin
                        if(instr[31:25] == 7'b0000000) alu_ctrl_r = ALU_SRL; 
                        else if(instr[31:25] == 7'b0100000) alu_ctrl_r = ALU_SRA;
                        else illegal_r = 1'b1;
                    end
                    
                    default: illegal_r = 1'b1; 
                endcase
            end           
//            LOAD_OPCODE: begin
                
//            end
//            JALR_OPCODE: begin
            
//            end
        endcase       
        
    end    

    assign RegWrite = reg_write_r; 
    assign ALUOp    = alu_ctrl_r;
    assign illegal  = illegal_r; 
    assign alu_src_ctrl = alu_src_r; 
endmodule

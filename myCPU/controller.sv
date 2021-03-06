`include "cpu_defs.svh"

module controller(
    
    input  logic       clk          , 
    input  logic       resetn       ,

    input instr_inf    dinstr       ,
    input logic        d_rtzero ,
    
    input  stage_val_1 flush    ,
    input  stage_val_1 stall    ,
         
    output ctrl_reg    dstage
    );
    
always_comb
begin
    unique case(dinstr.op)
        6'b011100:
        begin
            unique case (dinstr.funct)
                6'b110111: // LSA
                begin
                    dstage.alu_srcb_sel_rt <= 0;
                    dstage.sft_srcb_sel_rs <= 0;
                    dstage.out_sel <= 3'b111;
                    dstage.regwrite <= 1'b1;
                    dstage.regdst <= 2'b01;
                    dstage.reserved_instr <= 1'b0;
                end
                6'b000010: // MUL
                begin
                    dstage.alu_srcb_sel_rt <= 0;
                    dstage.sft_srcb_sel_rs <= 0;
                    dstage.out_sel <= 3'b100;
                    dstage.regwrite <= 1'b1;
                    dstage.regdst <= 2'b01;
                    dstage.reserved_instr <= 1'b0;
                end
                6'b000000: // MADD
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ; 
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000001: // MADDU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ; 
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000100: // MSUB
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ; 
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000101: // MSUBU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ; 
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100001: // CLO
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b101 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100000: // CLZ
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b101 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                default:
                begin
                    dstage.alu_srcb_sel_rt <= 0;
                    dstage.sft_srcb_sel_rs <= 0;
                    dstage.out_sel <= 3'b000;
                    dstage.regwrite <= 1'b0;
                    dstage.regdst <= 2'b00;
                    dstage.reserved_instr <= 1'b1;
                end
            endcase
        end
        6'b000000: 
        begin
            unique case(dinstr.funct)
                6'b100000: //ADD
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end    
                6'b100001: //ADDU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100010: //SUB
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100011: //SUBU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b101010: //SLT
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b101011: //SLTU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b011010: //DIV
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b011011: //DIVU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b011000: //MULT
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ; 
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b011001: //MULTU
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100100: //AND
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100111: //NOR
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100101: //OR
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b100110: //XOR
                begin
                    dstage.alu_srcb_sel_rt <= 1 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000100: //SLLV
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 1 ;
                    dstage.out_sel <= 3'b001 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000000: //SLL
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b001 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000111: //SRAV
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 1 ;
                    dstage.out_sel <= 3'b001 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000011: //SRA
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b001 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000110: //SRLV
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 1 ;
                    dstage.out_sel <= 3'b001 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b000010: //SRL
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;   
                    dstage.sft_srcb_sel_rs <= 0 ;    
                    dstage.out_sel <= 3'b001 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001000: //JR
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001001: //JALR
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b010000: //MFHI
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b010 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b010010: //MFLO
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b011 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b010001: //MTHI
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b010011: //MTLO
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001101: //BREAK
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001100://SYSCALL
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001011: //MOVN
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;   
                    dstage.sft_srcb_sel_rs <= 0 ;    
                    dstage.out_sel <= 3'b110 ;
                    dstage.regwrite <= !d_rtzero ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001010: //MOVZ
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;   
                    dstage.sft_srcb_sel_rs <= 0 ;    
                    dstage.out_sel <= 3'b110 ;
                    dstage.regwrite <= d_rtzero ;
                    dstage.regdst <= 2'b01 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                6'b001111: //SYNC AS NOP
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                default:
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b1 ;
                end
            endcase                                           
        end
        
        6'b001000://ADDI
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001001://ADDIU
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001010://SLTI
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001011://SLTIU
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001100://ANDI
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001111://LUI
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b001 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001101://ORI
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b001110://XORI
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b000100://BEQ
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b000101://BNE
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b010100://BEQL
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b010101://BNEL
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b000001:
        begin 
            unique case(dinstr.branchfunct)
                5'b00001: //BGEZ
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                5'b00000: //BLTZ
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b0 ;
                    dstage.regdst <= 2'b00 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                5'b10001: //BGEZAL
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b10 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                5'b10000: //BLTZAL
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b10 ;
                    dstage.reserved_instr <= 1'b0 ;
                end
                default:
                begin
                    dstage.alu_srcb_sel_rt <= 0 ;
                    dstage.sft_srcb_sel_rs <= 0 ;
                    dstage.out_sel <= 3'b000 ;
                    dstage.regwrite <= 1'b1 ;
                    dstage.regdst <= 2'b10 ;
                    dstage.reserved_instr <= 1'b1 ;
                end
            endcase                      
        end    
        6'b000111://BGTZ
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b000110://BLEZ
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b000010: //J
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b000011: //JAL
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b10 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100000://LB
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100100://LBU
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100001://LH
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100101://LHU
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100011://LW
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b110000://LL
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100010://LWL
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b100110://LWR
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b101000://SB
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b101001://SH
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b101011://SW
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b111000://SC
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b1 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b101010://SWL
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b101110://SWR
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b101111://CACHE AS NOP
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b110011: //PREF AS NOP
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b0 ;
        end
        6'b010000:
        begin
            if(dinstr.funct == 6'b011000)//ERET
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.c0funct == 5'b00000)//MFC0
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b1 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.c0funct == 5'b00100)//MTC0
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.funct == 6'b000001)//TLBR
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.funct == 6'b000010)//TLBWI
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.funct == 6'b000110)//TLBWR
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.funct == 6'b001000)//TLBP
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else if(dinstr.funct == 6'b100000)//WAIT
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b0 ;
            end
            else
            begin
                dstage.alu_srcb_sel_rt <= 0 ;
                dstage.sft_srcb_sel_rs <= 0 ;
                dstage.out_sel <= 3'b000 ;
                dstage.regwrite <= 1'b0 ;
                dstage.regdst <= 2'b00 ;
                dstage.reserved_instr <= 1'b1 ;
            end
        end

        default:
        begin
            dstage.alu_srcb_sel_rt <= 0 ;
            dstage.sft_srcb_sel_rs <= 0 ;
            dstage.out_sel <= 3'b000 ;
            dstage.regwrite <= 1'b0 ;
            dstage.regdst <= 2'b00 ;
            dstage.reserved_instr <= 1'b1 ;
        end

       
    endcase    
end

assign dstage.link = ((dinstr.op == 6'b000001) && (dinstr.branchfunct == 5'b10001)) //BGEZAL
        ||((dinstr.op == 6'b000001) && (dinstr.branchfunct == 5'b10000))   //BLTZAL
        ||(dinstr.op == 6'b000011) || ((dinstr.op == 6'b000000) && (dinstr.funct == 6'b001001 )) ;//JAL,JALR

assign dstage.isbranch = (dinstr.op == 6'b000100) || (dinstr.op == 6'b000101) || (dinstr.op == 6'b000001)
        || (dinstr.op == 6'b000111) || (dinstr.op == 6'b000110) || dinstr.op == 6'b010100 || dinstr.op == 6'b010101 ;

assign dstage.isjump =   ((dinstr.op == 6'b000000) && (dinstr.funct == 6'b001000))
        || ((dinstr.op == 6'b000000) && (dinstr.funct == 6'b001001))
        || (dinstr.op == 6'b000010) || (dinstr.op == 6'b000011) ;

assign dstage.likely = dinstr.op == 6'b010100 || dinstr.op == 6'b010101;



always_comb//dstage.branch
begin
    if(dinstr.op == 6'b000100 || dinstr.op == 6'b010100)
        dstage.branch = 3'b000 ;
    else if(dinstr.op == 6'b000101 || dinstr.op == 6'b010101)
        dstage.branch = 3'b001 ;
    else if(dinstr.op == 6'b000001 && dinstr.branchfunct == 5'b00001)
        dstage.branch = 3'b010 ;
    else if(dinstr.op == 6'b000111)
        dstage.branch = 3'b011 ;
    else if(dinstr.op == 6'b000110)
        dstage.branch = 3'b100 ;
    else if(dinstr.op == 6'b000001 && dinstr.branchfunct == 5'b00000)
        dstage.branch = 3'b101 ;
    else if(dinstr.op == 6'b000001 && dinstr.branchfunct == 5'b10001)
        dstage.branch = 3'b110 ;
    else if(dinstr.op == 6'b000001 && dinstr.branchfunct == 5'b10000)
        dstage.branch = 3'b111 ;
    else
        dstage.branch = 3'b000 ;
end

always_comb//dstage.jump
begin
    if(dinstr.op == 6'b000010)
        dstage.jump = 2'b00 ;//J
    else if(dinstr.op == 6'b000000 && dinstr.funct == 6'b001000)
        dstage.jump = 2'b01 ;//JR
    else if(dinstr.op == 6'b000011)
        dstage.jump = 2'b10 ;//JAL
    else if(dinstr.op == 6'b000000 && dinstr.funct == 6'b001001)
        dstage.jump = 2'b11 ;//JALR
    else
        dstage.jump = 2'b00 ;
end

assign dstage.memreq = (dinstr.op == 6'b100000) || (dinstr.op == 6'b100100)
    || (dinstr.op == 6'b100001) || (dinstr.op == 6'b100101) || (dinstr.op == 6'b100011)
    || (dinstr.op == 6'b101000) || (dinstr.op == 6'b101001) || (dinstr.op == 6'b101011)
    || dinstr.op == 6'b101010 || dinstr.op == 6'b101110 || dinstr.op == 6'b100010 || dinstr.op == 6'b100110
    || dinstr.op == 6'b110000 || dinstr.op == 6'b111000;

assign dstage.memwr =  dinstr.op == 6'b101000 || dinstr.op == 6'b101001 || dinstr.op == 6'b101011
    || dinstr.op == 6'b101010 || dinstr.op == 6'b101110 || dinstr.op == 6'b111000 ;  

always_comb//alu_func
begin
    if((dinstr.op == 6'b000000 && (dinstr.funct == 6'b100000 || dinstr.funct == 6'b100001)) || dinstr.op == 6'b001000 || dinstr.op == 6'b001001 || dstage.memreq)
        dstage.alu_func = 3'b000 ;
    else if((dinstr.op == 6'b000000) && (dinstr.funct == 6'b100010 || dinstr.funct == 6'b100011))
        dstage.alu_func = 3'b001 ;
    else if((dinstr.op == 6'b000000 && dinstr.funct == 6'b101010) || dinstr.op == 6'b001010) 
        dstage.alu_func = 3'b010 ;
    else if((dinstr.op == 6'b000000 && dinstr.funct == 6'b101011) || dinstr.op == 6'b001011)
        dstage.alu_func = 3'b011 ;
    else if((dinstr.op == 6'b000000 && dinstr.funct == 6'b100100) || dinstr.op == 6'b001100)
        dstage.alu_func = 3'b100 ;
    else if(dinstr.op == 6'b000000 && dinstr.funct == 6'b100111)
        dstage.alu_func = 3'b101 ;
    else if((dinstr.op == 6'b000000 && dinstr.funct == 6'b100101) || dinstr.op == 6'b001101)
        dstage.alu_func = 3'b110 ;
    else if((dinstr.op == 6'b000000 && dinstr.funct == 6'b100110) || dinstr.op == 6'b001110)
        dstage.alu_func = 3'b111 ;
    else
        dstage.alu_func = 3'b000 ;
end

always_comb//sft_func
begin
    if(dinstr.op == 6'b001111)
        dstage.sft_func = 2'b00 ;
    else if(dinstr.op == 6'b000000 && (dinstr.funct == 6'b000100 || dinstr.funct == 6'b000000))
        dstage.sft_func = 2'b01 ;
    else if(dinstr.op == 6'b000000 && (dinstr.funct == 6'b000111 || dinstr.funct == 6'b000011))
        dstage.sft_func = 2'b10 ;
    else if(dinstr.op == 6'b000000 && (dinstr.funct == 6'b000110 || dinstr.funct == 6'b000010))
        dstage.sft_func = 2'b11 ;
    else 
        dstage.sft_func = 2'b00 ;
end

assign dstage.cl_mode = dinstr.op == 6'b011100 && dinstr.funct == 6'b100001; // Only when CLO

assign dstage.intovf_en = ((dinstr.op == 6'b000000 && dinstr.funct == 6'b100000) || dinstr.op == 6'b001000 || (dinstr.op == 6'b000000 && dinstr.funct == 6'b100010)) ;

assign dstage.imm_sign = (dinstr.op == 6'b001000 || dinstr.op == 6'b001001 || dinstr.op == 6'b001010 || dinstr.op == 6'b001011) || 
(dinstr.op == 6'b100000 || dinstr.op == 6'b100100 || dinstr.op == 6'b100001 || dinstr.op == 6'b100101 || dinstr.op == 6'b100011 || dinstr.op == 6'b101000 || dinstr.op == 6'b101001 || dinstr.op == 6'b101011)
|| dinstr.op == 6'b110000 || dinstr.op == 6'b111000;

assign dstage.mul_en = (dinstr.op == 6'b000000 && (dinstr.funct == 6'b011000 || dinstr.funct == 6'b011001)) 
|| (dinstr.op == 6'b011100 && (dinstr.funct == 6'b000010 || dinstr.funct == 6'b000000 || dinstr.funct == 6'b000001 || dinstr.funct == 6'b000100 || dinstr.funct == 6'b000101));

assign dstage.mul_sign = (dinstr.op == 6'b000000 && dinstr.funct == 6'b011000) 
|| (dinstr.op == 6'b011100 && (dinstr.funct == 6'b000010 || dinstr.funct == 6'b000000 || dinstr.funct == 6'b000100)) ;

always_comb
    if (dinstr.op == 6'b000000 || dinstr.op == 6'b011100 && dinstr.funct == 6'b000010)
        dstage.mul_mode = 2'b00;
    else if (dinstr.op == 6'b011100 && (dinstr.funct == 6'b000000 || dinstr.funct == 6'b000001))
        dstage.mul_mode = 2'b01;
    else if (dinstr.op == 6'b011100 && (dinstr.funct == 6'b000100 || dinstr.funct == 6'b000101))
        dstage.mul_mode = 2'b10;
    else
        dstage.mul_mode = 2'b00;

assign dstage.div_en = (dinstr.op == 6'b000000 && (dinstr.funct == 6'b011010 || dinstr.funct == 6'b011011));

assign dstage.div_sign = (dinstr.op == 6'b000000 && dinstr.funct == 6'b011010) ;

always_comb//hi, lo
begin
    if(dinstr.op == 6'b000000 && (dinstr.funct == 6'b011001 || dinstr.funct == 6'b011000) || dinstr.op == 6'b011100 &&
        (dinstr.funct == 6'b000000 || dinstr.funct == 6'b000001 || dinstr.funct == 6'b000100 || dinstr.funct == 6'b000101))
    begin
        dstage.hi_sel = 2'b00 ;
        dstage.lo_sel = 2'b00 ;
        dstage.hi_wen = 1'b1  ;
        dstage.lo_wen = 1'b1  ;
    end
    else if(dinstr.op == 6'b000000 && (dinstr.funct == 6'b011010 || dinstr.funct == 6'b011011))
    begin
        dstage.hi_sel = 2'b01 ;
        dstage.lo_sel = 2'b01 ;
        dstage.hi_wen = 1'b1  ;
        dstage.lo_wen = 1'b1  ;
    end
    else if(dinstr.op == 6'b000000 && dinstr.funct == 6'b010001)
    begin
        dstage.hi_sel = 2'b10 ;
        dstage.lo_sel = 2'b00 ;
        dstage.hi_wen = 1'b1  ;
        dstage.lo_wen = 1'b0  ;
    end
    else if(dinstr.op == 6'b000000 && dinstr.funct == 6'b010011)
    begin
        dstage.hi_sel = 2'b00 ;
        dstage.lo_sel = 2'b10 ;
        dstage.hi_wen = 1'b0  ;
        dstage.lo_wen = 1'b1  ;
    end
    else
    begin
        dstage.hi_sel = 2'b00 ;
        dstage.lo_sel = 2'b00 ;
        dstage.hi_wen = 1'b0  ;
        dstage.lo_wen = 1'b0  ;
    end
end

always_comb
begin
    if(dinstr.op == 6'b100000 || dinstr.op == 6'b100100 || dinstr.op == 6'b101000)
        dstage.size = 2'b00 ;
    else if(dinstr.op == 6'b100001 || dinstr.op == 6'b100101 || dinstr.op == 6'b101001)
        dstage.size = 2'b01 ;
    else if(dinstr.op == 6'b100011 || dinstr.op == 6'b101011 || dinstr.op == 6'b100010 || dinstr.op == 6'b100110 || dinstr.op == 6'b101010 || dinstr.op == 6'b101110 || dinstr.op == 6'b110000 || dinstr.op == 6'b111000)
        dstage.size = 2'b10 ;
    else
        dstage.size = 2'b00 ;
end

assign dstage.mips_break = (dinstr.op == 6'b000000 && dinstr.funct == 6'b001101) ;
assign dstage.syscall = (dinstr.op == 6'b000000 && dinstr.funct == 6'b001100) ;

assign dstage.rdata_sign = (dinstr.op == 6'b100000 || dinstr.op == 6'b100001 || dinstr.op == 6'b100011 || dinstr.op == 6'b110000) ;
assign dstage.memtoreg = (dinstr.op == 6'b100000 || dinstr.op == 6'b100001 || dinstr.op == 6'b100011 || dinstr.op == 6'b100100 || dinstr.op == 6'b100101 || dinstr.op == 6'b100010 || dinstr.op == 6'b100110 || dinstr.op == 6'b110000) ;

assign dstage.eret = (dinstr.op == 6'b010000 && dinstr.funct == 6'b011000) ;

assign dstage.mfc0 = (dinstr.op == 6'b010000 && dinstr.c0funct == 5'b00000) ;
assign dstage.cp0_wen = (dinstr.op == 6'b010000 && dinstr.c0funct == 5'b00100) ;

assign dstage.sft_srca_sel_imm = (dinstr.op == 6'b001111);

always_comb
    if (dinstr.op == 6'b010000 && dinstr.funct == 6'b000001)
        dstage.tlb_req = TLBR;
    else if (dinstr.op == 6'b010000 && dinstr.funct == 6'b000010)
        dstage.tlb_req = TLBWI;
    else if (dinstr.op == 6'b010000 && dinstr.funct == 6'b000110)
        dstage.tlb_req = TLBWR;
    else if (dinstr.op == 6'b010000 && dinstr.funct == 6'b001000)
        dstage.tlb_req = TLBP;
    else
        dstage.tlb_req = NO_REQ;

always_comb
    if (dinstr.op == 6'b101010)
        dstage.swlr = 2'b01;
    else if (dinstr.op == 6'b101110)
        dstage.swlr = 2'b10;
    else
        dstage.swlr = 2'b00;

always_comb
    if (dinstr.op == 6'b100010)
        dstage.lwlr = 2'b01;
    else if (dinstr.op == 6'b100110)
        dstage.lwlr = 2'b10;
    else
        dstage.lwlr = 2'b00;

assign dstage.op_wait = dinstr.op == 6'b010000 && dinstr.funct == 6'b100000;

assign dstage.sc = dinstr.op == 6'b111000;

endmodule

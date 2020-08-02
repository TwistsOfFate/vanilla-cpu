module issue_controller(
    input  logic [5:0] d_op              , 
    input  logic [5:0] d_funct           ,
    input  logic [4:0] d_branchfunct     ,
    input  logic [4:0] d_c0funct         ,

    output logic       d_memreq          , //
    output logic       d_regwrite        , //
    output logic [1:0] d_regdst          , //  00rt 01rd 10r31
    output logic       d_hiwrite         , //
    output logic       d_lowrite         , //
     
    output logic       d_isbranch        , // 
    output logic       d_isjump          , //

    output logic       d_needrs          , //
    output logic       d_needrt          , //
    output logic       d_needhi          , //
    output logic       d_needlo          , //
    output logic       d_cp0rel           //
//    output logic       d_sys_jump             
);
    

// assign {d_memtoreg, d_regwrite, d_regdst, d_memreq, d_memwr , d_isbranch, d_branch, d_jump, d_alu_func, d_sft_func, d_imm_sign, d_mul_sign, d_div_sign, d_intovf_en, d_out_sel, d_alu_srcb_sel_rt, d_sft_srcb_sel_rs, d_link} = controls ;

always_comb
begin
    case(d_op)
        6'b011100:
        begin
            if (d_funct == 6'b000010)  // MUL
            begin
                d_regwrite <= 1'b1;
                d_regdst <= 2'b01;
                d_needrs <= 1'b1;
                d_needrt <= 1'b1;
            end
            else
            begin
                d_regwrite <= 1'b0;
                d_regdst <= 2'b00;
                d_needrs <= 1'b0;
                d_needrt <= 1'b0;
            end
        end
        6'b000000: 
        begin
            case(d_funct)
                6'b100000: //ADD
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end    
                6'b100001: //ADDU
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b100010: //SUB
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b100011: //SUBU
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b101010: //SLT
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b101011: //SLTU
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b011010: //DIV
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b011011: //DIVU
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b011000: //MULT
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b011001: //MULTU
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b100100: //AND
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b100111: //NOR
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b100101: //OR
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b100110: //XOR
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b000100: //SLLV
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b000000: //SLL
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b1 ;
                end
                6'b000111: //SRAV
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b000011: //SRA
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b1 ;
                end
                6'b000110: //SRLV
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b1 ;
                end
                6'b000010: //SRL
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b1 ;
                end
                6'b001000: //JR
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                6'b001001: //JALR
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                6'b010000: //MFHI
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b0 ;
                end
                6'b010010: //MFLO
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b01 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b0 ;
                end
                6'b010001: //MTHI
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                6'b010011: //MTLO
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                6'b001101: //BREAK
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b0 ;
                end
                6'b001100://SYSCALL
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b0 ;                   
                end
                default:
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b0 ;
                    d_needrt <= 1'b0 ;
                end
            endcase                                           
        end
        
        6'b001000://ADDI
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b001001://ADDIU
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b001010://SLTI
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b001011://SLTIU
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b001100://ANDI
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b001111://LUI
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b0 ;
            d_needrt <= 1'b0 ;
        end
        6'b001101://ORI
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b001110://XORI
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b000100://BEQ
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b1 ;
        end
        6'b000101://BNE
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b1 ;
        end
        6'b000001:
        begin 
            case(d_branchfunct)
                5'b00001: //BGEZ
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                5'b00000: //BLTZ
                begin
                    d_regwrite <= 1'b0 ;
                    d_regdst <= 2'b00 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                5'b10001: //BGEZAL
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b10 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                5'b10000: //BLTZAL
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b10 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
                default:
                begin
                    d_regwrite <= 1'b1 ;
                    d_regdst <= 2'b10 ;
                    d_needrs <= 1'b1 ;
                    d_needrt <= 1'b0 ;
                end
            endcase                      
        end    
        6'b000111://BGTZ
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b000110://BLEZ
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b000010: //J
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b0 ;
            d_needrt <= 1'b0 ;
        end
        6'b000011: //JAL
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b10 ;
            d_needrs <= 1'b0 ;
            d_needrt <= 1'b0 ;
        end
        6'b100000://LB
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b100100://LBU
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b100001://LH
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b100101://LHU
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b100011://LW
        begin
            d_regwrite <= 1'b1 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b0 ;
        end
        6'b101000://SB
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b1 ;
        end
        6'b101001://SH
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b1 ;
        end
        6'b101011://SW
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b1 ;
            d_needrt <= 1'b1 ;
        end

        6'b010000:
        begin
            if(d_funct == 6'b011000)//ERET
            begin
                d_regwrite <= 1'b0 ;
                d_regdst <= 2'b00 ;
                d_needrs <= 1'b0 ;
                d_needrt <= 1'b0 ;
            end
            else if(d_c0funct == 5'b00000)//MFC0
            begin
                d_regwrite <= 1'b1 ;
                d_regdst <= 2'b00 ;
                d_needrs <= 1'b0 ;
                d_needrt <= 1'b0 ;
            end
            else if(d_c0funct == 5'b00100)//MTC0
            begin
                d_regwrite <= 1'b0 ;
                d_regdst <= 2'b00 ;
                d_needrs <= 1'b0 ;
                d_needrt <= 1'b1 ;
            end
            else
            begin
                d_regwrite <= 1'b0 ;
                d_regdst <= 2'b00 ;
                d_needrs <= 1'b0 ;
                d_needrt <= 1'b0 ;
            end
        end

        default:
        begin
            d_regwrite <= 1'b0 ;
            d_regdst <= 2'b00 ;
            d_needrs <= 1'b0 ;
            d_needrt <= 1'b0 ;
        end

       
    endcase    
end

assign d_isbranch = ((d_op == 6'b000100) || (d_op == 6'b000101) || (d_op == 6'b000001)
        || (d_op == 6'b000111) || (d_op == 6'b000110)) ;

assign d_isjump =   ((d_op == 6'b000000) && (d_funct == 6'b001000))
        || ((d_op == 6'b000000) && (d_funct == 6'b001001))
        || (d_op == 6'b000010) || (d_op == 6'b000011) ;


assign d_memreq = ((d_op == 6'b100000) || (d_op == 6'b100100)
    || (d_op == 6'b100001) || (d_op == 6'b100101) || (d_op == 6'b100011)
    || (d_op == 6'b101000) || (d_op == 6'b101001) || (d_op == 6'b101011)) ;

assign d_cp0rel = (d_op == 6'b010000 && d_funct == 6'b011000)
    || (d_op == 6'b010000 && d_c0funct == 5'b00000)
    || (d_op == 6'b010000 && d_c0funct == 5'b00100) ;

assign d_needhi = (d_op == 6'b000000 && d_funct == 6'b010000) ;
assign d_needlo = (d_op == 6'b000000 && d_funct == 6'b010010) ;

assign d_hiwrite = (d_op == 6'b000000 && d_funct == 6'b010001)
    || (d_op == 6'b000000 && d_funct == 6'b011010)
    || (d_op == 6'b000000 && d_funct == 6'b011011)
    || (d_op == 6'b000000 && d_funct == 6'b011001)
    || (d_op == 6'b000000 && d_funct == 6'b011000) ;

assign d_lowrite = (d_op == 6'b000000 && d_funct == 6'b010011)
    || (d_op == 6'b000000 && d_funct == 6'b011010)
    || (d_op == 6'b000000 && d_funct == 6'b011011)
    || (d_op == 6'b000000 && d_funct == 6'b011001)
    || (d_op == 6'b000000 && d_funct == 6'b011000) ;  
    
//assign d_sys_jump = (d_op == 6'b010000 && d_funct == 6'b011000) || (d_op == 6'b000000 && d_funct == 6'b001101) || (d_op == 6'b000000 && d_funct == 6'b001100) ;     

endmodule

// Purpose: Decode step of the pipeline
// Functionality: Decodes the instruction and reads the register file
// File: DecodeStep.v

`include "definitions.vh";
module DecodeStep (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire [31:0] instruction_i, // Instruction input
    input wire [31:0] writebacked_result_i, // writebacked result to suitable register
    input wire reg_write_integer_i, //Write data flag for integer register file
    input wire reg_write_float_i, // Write data flag for float register file
    input wire reg_write_csr_i,  // Write data flag for csr register file
    input wire execute_working_info_i, // very important info for stalling
    output wire [6:0] opcode_o, // Opcode output
    output wire [4:0] rs1_o, // Source register 1 output
    output wire [4:0] rs2_o, // Source register 2 output
    output wire [4:0] rd_o, // Destination register output
    output wire [31:0] integer_operand1_o, // Operand 1 output
    output wire [31:0] integer_operand2_o, // Operand 2 output
    output wire [31:0] float_operand1_o,   // operand 1 for float 
    output wire [31:0] float_operand2_o,  // operand 2 for float
    output wire [31:0] float_operand3_o,   // operand 3 for float
    output wire [31:0] immediate_o, // Immediate output
    output wire [3:0] unit_type_o, // select corrrect unit depends on instruction
    output wire [4:0] instruction_type_o, // hold information of  which instruction
    output wire decode_finished_o, // Flag for finishing decode step
    output wire decode_working_info_o // output for decoding working info
);

reg decode_working_info = 1'b0; // very important info for stalling the decode and pipeline
reg decode_working_info_next = 1'b0; // next very important info for stalling the decode and pipeline

// Output signals
reg [6:0] opcode = 7'b0; // Opcode
reg [6:0] opcode_next = 7'b0; // Next opcode
reg [4:0] rs1 = 5'b0;// Source register 1
reg [4:0] rs1_next = 5'b0; // Next source register 1
reg [4:0] rs2 = 5'b0; // Source register 2 
reg [4:0] rs2_next = 5'b0; // Next source register 2
reg [4:0] rs3 = 5'b0; // Source register 3
reg [4:0] rs3_next = 5'b0; // Next source register 3
reg [4:0] rd = 5'b0; // Destination register
reg [4:0] rd_next = 5'b0; // Next destination register
wire [31:0] operand1_integer; // Operand 1
wire [31:0] operand2_integer; // Operand 2 
wire [31:0] operand1_float;  // Operand 1 for float
wire [31:0] operand2_float; // Operand 2 for float
wire [31:0] operand3_float; // Operand 3
reg [31:0] immediate = 32'b0; // Immediate
reg [31:0] immediate_next = 32'b0; // Next immediate


reg [3:0] unit_type = 4'b0000; //default zero will be changed later
reg [3:0] unit_type_next = 4'b0000; //default zero will be changed later

reg  [4:0] instruction_type = 5'b00000; // instruction type will be conveyed to execute step
reg  [4:0] instruction_type_next = 5'b00000; // next instruction type will be conveyed to execute step

reg  [1:0] register_selection = `INTEGER_REGISTER;  // register selection for register file
reg [1:0]  register_selection_next = `INTEGER_REGISTER; // next register selection for register file
 
// Integer Register File module
IntegerRegisterFile integerRegisterFile(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .rs1_i(rs1), // Source register 1   
    .rs2_i(rs2), // Source register 2
    .rd_i(rd), // Destination register
    .write_data_i(writebacked_result_i), // Writebacked result
    .reg_write_i(reg_write_integer_i), // Write data flag
    .read_data1_o(operand1_integer),    // Operand 1
    .read_data2_o(operand2_integer)   // Operand 2
);


// Float Register File module
FloatRegisterFile floatRegisterFile(
    .clk_i(clk_i), // Clock input
    .rst_i(rst_i), // Reset input
    .rs1_i(rs1), // Source register 1
    .rs2_i(rs2), // Source register 2
    .rs3_i(rs3), // Source register 3
    .rd_i(rd), // Destination register
    .write_data_i(writebacked_result_i),    // Writebacked result
    .reg_write_i(reg_write_float_i), // Write data flag
    .read_data1_o(operand1_float), // Operand 1
    .read_data2_o(operand2_float), // Operand 2
    .read_data3_o(operand3_float) // Operand 3
);

//Decode modul implementation
reg decode_finished = 1'b0; // Flag for finishing decode step // important change
reg decode_finished_next = 1'b0; // Next flag for finishing decode step // important change
wire isWorking; // Flag for working

localparam FIRST_CYCLE = 3'b000; // State for first cycle
localparam SECOND_CYCLE = 3'b001; // State for second cycle
localparam STALL = 3'b010;       // stall information for stalling pipeline

reg [2:0] STATE = FIRST_CYCLE; // State for the module
reg [2:0] STATE_NEXT = FIRST_CYCLE; // Next state for the module

reg [31:0] imm_generated_operand2 = 32'b0; // imm generated operand2
reg [31:0] imm_generated_operand2_next = 32'b0; // next imm generated operand2  
reg enable_generate = 1'b0; // enable generate                                   // do not implemet next logic for this important for immediate generation

integer i = 1; // debugging for which instruction decoded

assign isWorking = enable_step_i && decode_finished != 1'b1; // Assign isWorking

// Decode module implementation
always @(*) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin // First cycle

                // Update the next register values
                opcode_next = opcode; // Assign opcode to next opcode
                rs1_next = rs1; // Assign source register 1 to next source register 1
                rs2_next = rs2; // Assign source register 2 to next source register 2
                rs3_next = rs3; // Assign source register 3 to next source register 3
                rd_next = rd; // Assign destination register to next destination register
                immediate_next = immediate; // Assign immediate to next immediate
                unit_type_next = unit_type; // Assign unit type to next unit type
                instruction_type_next = instruction_type; // Assign instruction type to next instruction type
                imm_generated_operand2_next = imm_generated_operand2; // Assign imm generated operand2 to next imm generated operand2
                decode_finished_next = decode_finished; // Assign decode finished to next decode finished
                STATE_NEXT = STATE; // Assign state to next state
                register_selection_next = register_selection; // Assign register selection to next register selection
                decode_working_info_next = 1'b1; // Set the working info for decode stepS


                decode_working_info_next = 1'b1; // Set the working info for decode step
                if(execute_working_info_i) begin
                    $display("EXECUTE STILL WORKING DECODE WAITING");
                    STATE_NEXT = STALL;
                end
                else begin
                $display("DECODE STEP Decoding instruction %h", instruction_i, " for instruction %d",i); // Display the instruction
                opcode_next = instruction_i[6:0]; // Extract opcode not that not use <= here 
                case(opcode_next) // Extract the opcode
                    7'b0010011: begin
                        register_selection_next = `INTEGER_REGISTER; // Set the register selection
                        rs1_next = instruction_i[19:15]; // Extract source register 1
                        rd_next = instruction_i[11:7];   // Extract destination register
                        immediate_next = instruction_i[31:20]; // Extract immediate
                        unit_type_next = `ARITHMETIC_LOGIC_UNIT; // Set the unit type
                        enable_generate = 1'b1;    // enable generate                                
                        case(instruction_i[14:12]) // Extract the instruction type
                            3'b000 : begin
                                 generate_operand2(instruction_i); // Generate operand 2
                                 instruction_type_next = `ALU_ADDI; // Set the instruction type
                            end
                            3'b010 : begin 
                                generate_operand2(instruction_i); // Generate operand 2
                                instruction_type_next = `ALU_SLTI; // Set the instruction type
                            end
                            3'b011 : begin 
                                 generate_operand2(instruction_i); // Generate operand 2
                                instruction_type_next = `ALU_SLTIU; // Set the instruction type
                            end
                            3'b100 : begin 
                                generate_operand2(instruction_i); // Generate operand 2
                                instruction_type_next = `ALU_XORI; // Set the instruction type
                            end
                            3'b110 : begin 
                                generate_operand2(instruction_i); // Generate operand 2
                                instruction_type_next = `ALU_ORI; // Set the instruction type
                            end
                            3'b111 : begin
                                generate_operand2(instruction_i);  // Generate operand 2
                                instruction_type_next = `ALU_ANDI; // Set the instruction type
                            end
                            3'b001 : instruction_type_next = `ALU_SLLI; // Set the instruction type
                            3'b101 : begin 
                                if(instruction_i[31:25] == 6'b000000) // Extract the instruction type
                                    instruction_type_next = `ALU_SRLI; // Set the instruction type
                                else
                                    instruction_type_next = `ALU_SRAI; // Set the instruction type
                            end
                        endcase
                    end
                    7'b0110011: begin
                        register_selection_next = `INTEGER_REGISTER; // Set the register selection
                        enable_generate =1'b0; // disable generate
                        rs1_next = instruction_i[19:15]; // Extract source register 1
                        rs2_next = instruction_i[24:20]; // Extract source register 2
                        rd_next = instruction_i[11:7];   // Extract destination register
                        unit_type_next = `ARITHMETIC_LOGIC_UNIT; // Set the unit type
                        case(instruction_i[14:12]) // Extract the instruction type
                            3'b000 : begin
                                if(instruction_i[25] == 1'b1) // Extract the instruction type
                                begin
                                    unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_MUL; // Set the instruction type
                                end
                                else if(instruction_i[30] == 1'b0)
                                    instruction_type_next = `ALU_ADD; // Set the instruction type
                                else
                                    instruction_type_next = `ALU_SUB; // Set the instruction type
                            end
                            3'b001 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_MULH; // Set the instruction type
                                end
                                else
                                    instruction_type_next= `ALU_SLL; // Set the instruction type
                            end
                            3'b010 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_MULHSU; // Set the instruction type
                                end
                                else
                                    instruction_type_next = `ALU_SLT; // Set the instruction type
                            end
                            3'b011 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type_next = `INTEGER_MULTIPLICATION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_MULHU; // Set the instruction type
                                end
                                else
                                    instruction_type_next = `ALU_SLTU; // Set the instruction type
                            end
                            3'b100 : begin instruction_type_next = `ALU_XOR; // Set the instruction type
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_DIV; // Set the instruction type
                                end
                                else
                                    instruction_type_next = `ALU_XOR; // Set the instruction type
                            end
                            3'b101 : begin
                                if(instruction_i[25] == 1'b1)
                                   begin
                                    unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_DIVU; // Set the instruction type
                                   end
                                else if(instruction_i[30] == 1'b1)
                                    instruction_type_next = `ALU_SRA; // Set the instruction type
                                else
                                    instruction_type_next = `ALU_SRL; // Set the instruction type
                            end
                            3'b110 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_REM; // Set the instruction type
                                end
                                else
                                    instruction_type_next = `ALU_OR; // Set the instruction type
                            end
                            3'b111 : begin
                                if(instruction_i[25] == 1'b1)
                                begin
                                    unit_type_next = `INTEGER_DIVISION_UNIT; // Set the unit type
                                    instruction_type_next = `INT_REMU; // Set the instruction type
                                end
                                else
                                    instruction_type_next = `ALU_AND; // Set the instruction type
                            end
                        endcase
                    end
                  7'b0101111: begin
                       register_selection_next = `INTEGER_REGISTER; // set register selection
                       rs1_next = instruction_i[19:15]; // Extract source register 1
                       rs2_next = instruction_i[24:20]; // Extract source register 2
                       rd_next = instruction_i[11:7];   // Extract destination register
                       unit_type_next = `ATOMIC_UNIT;   // set unit type as atomic unit
                       case(instruction_i[31:27])
                            5'b00010: instruction_type_next = `ATOM_LOAD; // set instruction type
                            5'b00011: instruction_type_next = `ATOM_STORE; // set instruction type
                            5'b00001: instruction_type_next = `ATOM_SWAP;   // set instruction type
                            5'b00000: instruction_type_next = `ATOM_ADD;   // set instruction type
                            5'b00100: instruction_type_next = `ATOM_XOR;  // set instruction type
                            5'b01100: instruction_type_next = `ATOM_AND; // set instruction type
                            5'b01000: instruction_type_next = `ATOM_OR; // set instruction type
                            5'b10000: instruction_type_next = `ATOM_MIN; // set instruction type
                            5'b10100: instruction_type_next = `ATOM_MAX; // set instruction type
                            5'b11000: instruction_type_next = `ATOM_MINU; // set instruction type
                            5'b11100: instruction_type_next = `ATOM_MAXU; // set instruction type
                      endcase
                end
                7'b0000111: begin
                    rs1_next = instruction_i[19:15]; // Extract source register 1
                    rs2_next = instruction_i[24:20]; // Extract source register 2
                    rs3_next = instruction_i[31:27]; // Extract source register 3
                    rd_next = instruction_i[11:7];   // Extract destination register
                    instruction_type_next = `FLT_LOAD; // set instruction type
                    unit_type_next = `FLOATING_POINT_UNIT; // set unit type
                    generate_operand2(instruction_i); // generate operand 2
                    enable_generate = 1'b1; // enable generate
                end
                7'b0100111: begin
                    rs1_next = instruction_i[19:15]; // Extract source register 1
                    rs2_next = instruction_i[24:20]; // Extract source register 2
                    rs3_next = instruction_i[31:27]; // Extract source register 3
                    rd_next = instruction_i[11:7];   // Extract destination register
                    instruction_type_next = `FLT_STORE; // set instruction type
                    unit_type_next = `FLOATING_POINT_UNIT; // set unit type
                    imm_generated_operand2_next[4:0] <= instruction_i[11:7]; // set value
                    imm_generated_operand2_next[11:5] <= instruction_i[31:25]; // set value
                    if(instruction_i[31] == 1'b0) 
                        imm_generated_operand2_next[31:12] = 20'b0; // extend with zero
                    else
                        imm_generated_operand2_next[31:12] = 20'b1; // extend with one                               
                end
                7'b1000011: begin
                   rs1_next = instruction_i[19:15]; // Extract source register 1
                   rs2_next = instruction_i[24:20]; // Extract source register 2
                   rs3_next = instruction_i[31:27]; // Extract source register 3
                   rd_next = instruction_i[11:7];   // Extract destination register
                   instruction_type_next = `FLT_FMADD; // set instruction type
                   unit_type_next = `FLOATING_POINT_UNIT;    // set unit type
               end 
               7'b1000111:
                    begin
                       rs1_next = instruction_i[19:15]; // Extract source register 1
                       rs2_next = instruction_i[24:20]; // Extract source register 2
                       rs3_next = instruction_i[31:27]; // Extract source register 3
                       rd_next = instruction_i[11:7];   // Extract destination register
                       instruction_type_next = `FLT_FMSUB;  // set instruction type
                       unit_type_next = `FLOATING_POINT_UNIT;  // set unit type
                    end
               7'b1001011: begin
                   rs1_next = instruction_i[19:15]; // Extract source register 1
                   rs2_next = instruction_i[24:20]; // Extract source register 2
                   rs3_next = instruction_i[31:27]; // Extract source register 3
                   rd_next = instruction_i[11:7];   // Extract destination register
                   instruction_type_next = `FLT_FNMSUB;  // set instruction type
                   unit_type_next = `FLOATING_POINT_UNIT; // set unit type                                
                end
                7'b1001111: begin
                   rs1_next = instruction_i[19:15]; // Extract source register 1
                   rs2_next = instruction_i[24:20]; // Extract source register 2
                   rs3_next = instruction_i[31:27]; // Extract source register 3
                   rd_next = instruction_i[11:7];   // Extract destination register
                   instruction_type_next = `FLT_FNMADD; // set instruction type
                   unit_type_next = `FLOATING_POINT_UNIT; // set unit type                               
                end
                7'b1010011: begin
                   rs1_next = instruction_i[19:15]; // Extract source register 1
                   rs2_next = instruction_i[24:20]; // Extract source register 2
                   rs3_next = instruction_i[31:27]; // Extract source register 3
                   rd_next = instruction_i[11:7];   // Extract destination register                           
                   unit_type_next = `FLOATING_POINT_UNIT; // set unit type
                   case(instruction_i[31:25])
                        7'b0000000: instruction_type_next = `FLT_FADD; // set instruction type
                        7'b0000100: instruction_type_next = `FLT_FSUB; // set instruction type
                        7'b0001000: instruction_type_next = `FLT_FMUL; // set instruction type
                        7'b0001100: instruction_type_next = `FLT_FDIV; // set instruction type
                        7'b0101100: instruction_type_next = `FLT_FSQRT; // set instruction type
                        7'b0010000:
                            begin
                                if(instruction_i[14:12] == 3'b000)
                                    instruction_type_next = `FLT_FSGNJ; // set instruction type
                                else if(instruction_i[14:12] == 3'b001)
                                    instruction_type_next = `FLT_FSGNJN;    // set instruction type
                                else  
                                    instruction_type_next = `FLT_FSGNJX; // set instruction type
                            end
                       7'b0010100:
                            begin
                                if(instruction_i[14:12] == 3'b000)
                                    instruction_type_next = `FLT_FMIN; // set instruction type
                                else
                                    instruction_type_next = `FLT_FMAX; // set instruction type
                            end
                      7'b1100000:
                            begin
                                if(instruction_i[24:20] == 5'b00000)
                                    instruction_type_next = `FLT_FCVTW; // set instruction type
                                else
                                    instruction_type_next = `FLT_FCVTWU; // set instruction type                                          
                            end
                      7'b1110000:
                            begin
                                if(instruction_i[14:12] == 3'b000)
                                    instruction_type_next = `FLT_FMVXW; // set instruction type
                                else
                                    instruction_type_next = `FLT_FCLASS;    // set instruction type
                            end
                      7'b1010000:
                            begin
                                if(instruction_i[14:12] == 3'b010)
                                    instruction_type_next = `FLT_FEQ; // set instruction type
                                else if(instruction_i[14:12] == 3'b001)
                                    instruction_type_next = `FLT_FLT; // set instruction type
                                else 
                                    instruction_type_next = `FLT_FLE;       // set instruction type               
                            end
                      7'b1101000:
                            begin
                                if(instruction_i[20] == 1'b0)
                                    instruction_type_next = `FLT_FCVTSW; // set instruction type
                                else 
                                    instruction_type_next = `FLT_FCVTSWU; // set instruction type
                            end
                       7'b1111000: instruction_type_next = `FLT_FMVWX; // set instruction type
                   endcase                     
                  end
                endcase
                
                    STATE_NEXT = SECOND_CYCLE;       // Go to the second cycle
                    end //do not forget this
                end
                SECOND_CYCLE : begin
                    $display("-->Decoding completed for instruction  num %d",i);
                    $display("-->IMM %d",imm_generated_operand2);
                    $display("-->Opcode: %b", opcode); // Display opcode
                    $display("-->rs1: %d", rs1);       // Display source register 1
                    $display("-->rs2: %d", rs2);       // Display source register 2
                    $display("-->rd: %d", rd);         // Display destination register
                    $display("--> Operand1 %d",operand1_integer);  
                    $display("--> Operand2 %d",operand2_integer);  
                    decode_finished_next = 1'b1;         // Set the flag for finishing decode step  
                    STATE_NEXT = FIRST_CYCLE;            // Go back to the first cycle
                    i=i+1;                        // Increment the instruction number
                    decode_working_info_next = 1'b0;     // Set the working info to 0
                end
                STALL : begin
                    $display("STALL FOR DECODE"); // Display the stall info
                    STATE_NEXT = FIRST_CYCLE; // Go to the second cycle
                end 
            endcase        
        end
end

always@(posedge clk_i) begin
    if(rst_i) begin
        opcode <= 7'b0; // Assign opcode to 0
        rs1 <= 5'b0; // Assign source register 1 to 0
        rs2 <= 5'b0; // Assign source register 2 to 0
        rs3 <= 5'b0; // Assign source register 3 to 0
        rd <= 5'b0; // Assign destination register to 0
        immediate <= 32'b0; // Assign immediate to 0
        unit_type <= 4'b0000; // Assign unit type to 0
        instruction_type <= 5'b00000; // Assign instruction type to 0
        imm_generated_operand2 <= 32'b0; // Assign imm generated operand2 to 0
        decode_finished <= 1'b0; // Assign decode finished to 0
        decode_working_info <= 1'b0; // Assign decode working info to 0
        STATE <= FIRST_CYCLE; // Assign state to first cycle
    end
    else begin
        if(isWorking) begin
            opcode <= opcode_next; // Assign next opcode to opcode
            rs1 <= rs1_next; // Assign next source register 1 to source register 1
            rs2 <= rs2_next; // Assign next source register 2 to source register 2
            rs3 <= rs3_next; // Assign next source register 3 to source register 3
            rd <= rd_next; // Assign next destination register to destination register
            immediate <= immediate_next; // Assign next immediate to immediate
            unit_type <= unit_type_next; // Assign next unit type to unit type
            instruction_type <= instruction_type_next; // Assign next instruction type to instruction type
            imm_generated_operand2 <= imm_generated_operand2_next; // Assign next imm generated operand2 to imm generated operand2
            decode_finished <= decode_finished_next; // Assign next decode finished to decode finished
            register_selection <= register_selection_next; // Assign next register selection to register selection
            decode_working_info <= decode_working_info_next; // Assign next decode working info to decode working info
            STATE <= STATE_NEXT; // Assign next state to state
        end
    end
end
   
assign decode_finished_o = decode_finished; // Assign the flag for finishing decode step
assign opcode_o = opcode;                   // Assign the opcode        
assign rs1_o = rs1;                         // Assign source register 1
assign rs2_o = rs2;                         // Assign source register 2
assign rd_o = rd;                           // Assign destination register
assign integer_operand1_o = operand1_integer;
assign integer_operand2_o = (enable_generate)? imm_generated_operand2 : operand2_integer; // Assign operand 2 depending on the instruction
assign float_operand1_o = operand1_float;  // Assign float operand 1
assign float_operand2_o = operand2_float; // Assign float operand 2
assign float_operand3_o = operand3_float; // Assign float operand 3
assign immediate_o = immediate;             // Assign immediate 
assign unit_type_o = unit_type;             // Assign unit type       
assign instruction_type_o = instruction_type; // Assign instruction
assign decode_working_info_o = decode_working_info; // Assign decode working info

/*
    * Task to generate operand2
    * @param instruction_i
*/
task generate_operand2(
    input [31:0] instruction_i
);

    begin
        imm_generated_operand2_next[11:0] = instruction_i[31:20]; // set value
        if(instruction_i[31] == 1'b0)
            imm_generated_operand2_next[31:12] = 20'b0; // extend with zero
        else
            imm_generated_operand2_next[31:12] = 20'b1; // extend with one
    end
endtask



endmodule
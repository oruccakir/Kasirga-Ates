// Purpose: Execute Step 1 of the pipeline.
// Functionality: This module performs the first part of the execute stage of the pipeline.
// File: ExecuteStep1.v

include "definitions.vh";

module ExecuteStep1 (
    input wire clk_i, // Clock input
    input wire rst_i, // Reset input
    input wire enable_step_i, // Enable input
    input wire data_completed_i, // data completed comes from helper memory
    input wire [31:0] data_i,    // comes from memory that will assign to calculated result 
    input wire [4:0] rd_i, // Destination register input from decode step
    input wire [31:0] operand1_integer_i, // Operand 1 input comes from decode integer register file
    input wire [31:0] operand2_integer_i, // Operand 2 input comes from decode integer register file or from another calculation logic
    input wire [31:0] rs2_value_i,        // rs2 register value comes from decode integer register file
    input wire [31:0] operand1_float_i,   // Operand 1 input comes from decode float register file
    input wire [31:0] operand2_float_i,   // Operand 2 input comes from decode float register file
    input wire [31:0] operand3_float_i,   // Operand 3 input comes from decode float register file
    input wire [3:0] unit_type_i,         // for unit selection input comes from decode step for unit selection
    input wire [4:0] instruction_type_i,  // instruction type it works inside of unit type selection logic depending on definitions step
    input wire [1:0]register_selection_i,       // register selection info, comes from decode step
    input wire [31:0] program_counter_i,     // comes from decode for branch instructions and for other necessary instructions
    input wire [31:0] immediate_value_i,     // comes from decode step for branch and other instructions
    output wire [31:0] calculated_result_o, // calculated result output, goes to memory step
    output wire execute1_finished_o,      // Flag for finishing execute step 1
    output wire execute_working_info_o,   // Execute step working info, goes to decode step
    output wire [4:0] rd_o,               // Target register info, goes to memory step
    output wire [1:0] register_selection_o, // this info comes from decode step as input goes to memory step as output
    output wire is_branch_address_calculated_o, // this goes to fetch step for branch address calculation, indicating whether completed or not
    output wire [31:0] calculated_branch_address_o, // this goes to fetch step for branch address calculation, gives calculated branch address
    output wire [31:0] data_address_o,// comes from memory that will assign to calculated result 
    output wire read_enable_o, // read enable output goes to processor from there goes to memory
    output wire write_enable_o, // write enable output goes to processor from there goes to memory
    output wire [31:0] mem_address_o,  // Memory address output goes to memory
    output wire [31:0] mem_writed_data_o, // Memory data output goes to memory
    output wire branch_info_o, // comes from branch resolver unit as output and goes to fetch step 
    output wire [2:0] write_register_info_o // goes to writeback step for writing process
);

reg [3:0] unit_type = 4'b0000;  // unit type, goes to memory step
reg [31:0] calculated_result = 32'b0; // reg for assign calculated result to calculated result output goes to memory step
reg [4:0] rd = 5'b0;                // target register index, goes to memory step
reg execute_working_info = 1'b0;   //  very important info for stalling goes to decode step
reg [1:0]register_selection = 2'b0;    // register selection info goes to memory step

reg enable_alu_unit = 1'b0; // Enable signal for ALU unit
reg enable_integer_multiplication_unit = 1'b0; // Enable signal for integer multiplication unit
reg enable_integer_division_unit = 1'b0; // Enable signal for integer division unit
reg enable_floating_point_unit = 1'b0; // Enable signal for floating point unit
reg enable_branch_resolver_unit = 1'b0; // Enable signal for branch resolver unit
reg enable_control_unit = 1'b0; // Enable signal for control unit
reg enable_control_status_unit = 1'b0; // Enable signal for control status unit
reg enable_atomic_unit = 1'b0; // Enable signal for atomic unit
reg enable_bit_manipulation_unit = 1'b0; // Enable signal for bit manipulation unit
reg enable_memory_unit = 1'b0;          // Enable signal for memory unit

wire finished_alu_unit; // finished signal for ALU unit
wire finished_integer_multiplication_unit; // finished signal for integer multiplication unit
wire finished_integer_division_unit; // finished signal for integer division unit
wire finished_floating_point_unit; // finished signal for floating point unit
wire finished_branch_resolver_unit; // finished signal for branch resolver unit
wire finished_control_unit; // finished signal for control unit
wire finished_control_status_unit; // finished signal for control status unit
wire finished_atomic_unit; // finished signal for atomic unit
wire finished_bit_manipulation_unit;// finished signal for bit manipulation unit
wire finished_memory_unit;     // finished signal for memory unit

//results
wire [31:0] calculated_alu_result;    // alu result reg
wire [31:0] calculated_int_mul_result; // int multiplication unit result reg
wire [31:0] calculated_int_div_result;  // int division unit result reg
wire [31:0] calculated_fpu_result;      // floating point unit result reg
wire [31:0] calculated_branch_result;   // bransh resolver unit result reg
wire [31:0] calculated_bit_manip_result;  //  bit manipulation unit result reg
wire [31:0] calculated_atomic_result;      // atomic unit result reg
wire [31:0] calculated_control_status_result; // control status unit result reg 
wire [31:0] calculated_memory_unit_result;   // memory_unit result reg

reg is_branch_address_calculated = 1'b0; // for branch instructions indicate branch calculation

reg other_resources = 1'b0;
// Arithmetic Logic Unit module
ArithmeticLogicUnit arithmetic_logic_unit(
    .enable_i(enable_alu_unit),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .aluOp_i(instruction_type_i),
    .other_resources_i(other_resources),
    .result_o(calculated_alu_result)
);

// Integer Multiplication Unit module
IntegerMultiplicationUnit integer_multiplication_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_integer_multiplication_unit),
    .mulOp_i(instruction_type_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_mul_result),
    .is_finished_o(finished_integer_multiplication_unit)
);

// Integer Division Unit module
IntegerDivisionUnit integer_division_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_integer_division_unit),
    .divOp_i(instruction_type_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_div_result),
    .is_finished_o(finished_integer_division_unit)
);

// Floating Point Unit module
FloatingPointUnit floating_point_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_floating_point_unit)
);

// Branch Resolver Unit module
BranchResolverUnit branch_resolver_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_branch_resolver_unit),
    .instruction_type_i(instruction_type_i),
    .program_counter_i(program_counter_i),
    .immediate_value_i(immediate_value_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_branch_result),
    .branch_info_o(branch_info_o)
);

// Control Unit module
ControlUnit control_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_control_unit)
);

// Control Status Unit module
ControlStatusUnit control_status_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_control_status_unit)
);

// Atomic Unit module
AtomicUnit atomic_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_atomic_unit)
);

// Bit Manipulation Unit module
BitManipulationUnit bit_manipulation_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_bit_manipulation_unit)
);

// Memory Unit
MemoryUnit memory_unit(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_i(enable_memory_unit),
    .data_i(data_i),
    .data_completed_i(data_completed_i),
    .memOp_i(instruction_type_i[2:0]),
    .mem_stored_data_i(rs2_value_i),
    .calculated_memory_address_i(calculated_alu_result),
    .mem_data_o(mem_writed_data_o),
    .mem_address_o(mem_address_o),
    .write_enable_o(write_enable_o),
    .read_enable_o(read_enable_o),
    .mem_data_for_writeback_o(calculated_memory_unit_result),
    .is_finished_o(finished_memory_unit)
);

// ExecuteStep1 module implementation
reg execute1_finished = 1'b0; // Flag for finishing execute step 1 
wire isWorking; // Flag for working
integer i = 1; // it is just for debugging the instruction number

localparam FIRST_CYCLE = 3'b000; // State for desiring instruction
localparam SECOND_CYCLE = 3'b001; // State for instruction result
localparam STALL = 3'b010;        // State for stalling the execute step
reg [2:0] STATE = FIRST_CYCLE; // State for the module

assign isWorking = enable_step_i && execute1_finished != 1'b1; // Assign isWorking

always @(posedge clk_i) begin
    if(isWorking) begin
        case(STATE)
            FIRST_CYCLE : begin
                execute1_finished = 1'b0;
                execute_working_info = 1'b1;
                is_branch_address_calculated = 1'b0;
                //rd = rd_i;
                $display("EXECUTE STEP Executing instruction for instruction num %d",i);
                case(unit_type_i)
                    `NONE_UNIT : begin
                        $display("LUI");
                        STATE = SECOND_CYCLE; // Go to the second cycle
                     end
                    `ARITHMETIC_LOGIC_UNIT: begin
                        enable_alu_unit = 1'b1; // Enable ALU unit
                        $display("ALU Working");
                        case(instruction_type_i)
                            `ALU_ADD : $display("ADD");
                            `ALU_SUB: $display("SUB");
                            `ALU_AND: $display("AND");                            
                            `ALU_OR:  $display("OR");
                            `ALU_XOR: $display("XOR");
                            `ALU_SLL: $display("SLL");
                            `ALU_SRL: $display("SRL");
                            `ALU_SRA: $display("SRA");
                            `ALU_SLT: $display("SLT");
                            `ALU_SLTU: $display("SLTU");
                            `ALU_SLLI: $display("SLLI");
                            `ALU_SRLI: $display("SRLI");
                            `ALU_SRAI: $display("SRAI");
                            `ALU_ADDI: $display("ADDI");
                            `ALU_ANDI: $display("ANDI");
                            `ALU_ORI: $display("ORI");
                            `ALU_XORI: $display("XORI");
                            `ALU_SLTI: $display("SLTI");
                            `ALU_SLTIU: $display("SLTIU");
                        endcase
                    end
                    `INTEGER_MULTIPLICATION_UNIT: begin
                        // Enable integer multiplication unit
                        enable_integer_multiplication_unit = 1'b1;
                        $display("Integer Multiplication Unit working for instruction %d",i);
                        case(instruction_type_i)
                            `INT_MUL: $display("MUL");
                            `INT_MULH: $display("MULH");
                            `INT_MULHSU: $display("MULHSU");
                            `INT_MULHU: $display("MULHU");
                        endcase
                    end
                    `INTEGER_DIVISION_UNIT: begin
                        // Enable integer division unit
                        enable_integer_division_unit = 1'b1;
                        $display("Integer Division Unit working");
                        case(instruction_type_i)
                            `INT_DIV: $display("DIV");
                            `INT_DIVU: $display("DIVU");
                            `INT_REM: $display("REM");
                            `INT_REMU: $display("REMU");
                        endcase
                    end
                    `FLOATING_POINT_UNIT:begin
                        // Enable floating point unit
                        enable_floating_point_unit = 1'b1;
                        $display("Floating Point Unit working");
                    end
                    `BRANCH_RESOLVER_UNIT: begin
                        // Enable branch resolver unit 
                        enable_branch_resolver_unit = 1'b1;
                        if(instruction_type_i == `BRANCH_JAL || `BRANCH_JALR) begin
                            other_resources = 1'b1;
                            $display("Enable otherr");
                            enable_alu_unit = 1'b1; // no importance
                        end
                        $display("Branch Resolver Unit working");
                        $display("Program counter ",program_counter_i);
                        $display("Immediate",immediate_value_i);
                        $display("Rs1 value ",operand1_integer_i);
                        $display("Rs2 value ",operand2_integer_i);
                    end 
                    `CONTROL_UNIT: begin
                        // Enable control unit
                        enable_control_unit = 1'b1;
                        $display("Control Unit working");
                    end
                    `CONTROL_STATUS_UNIT: begin
                        // Enable control status unit
                        enable_control_status_unit = 1'b1;
                        $display("Control Status Unit working");
                    end
                    `ATOMIC_UNIT: begin
                        // Enable atomic unit
                        enable_atomic_unit = 1'b1;
                        $display("Atomic Unit working");
                    end
                    `BIT_MANIPULATION_UNIT: begin
                        // Enable bit manipulation unit
                        enable_bit_manipulation_unit = 1'b1;
                        $display("Bit Manipulation Unit working");
                    end
                    `MEMORY_UNIT: begin
                        enable_alu_unit = 1'b1; // no importance
                        other_resources = 1'b1;
                        enable_memory_unit = 1'b1;
                        $display("Memory address calculation is being done for instruction ",i);
                        //mem_op = instruction_type_i[2:0];
                        //mem_instruction = 1'b1;;
                    end
                endcase
                STATE = SECOND_CYCLE; // Go to the second cycle
            end
            SECOND_CYCLE : begin
                case(unit_type_i)
                    `NONE_UNIT: begin
                        $display("NONE UNIT INSTRUCTON");
                        calculated_result = operand2_integer_i;
                        $display("-->Execution completed for instruction num %d",i);
                        $display("Result after execution %d",calculated_result);
                        i=i+1;
                        execute1_finished = 1'b1; 
                        STATE = FIRST_CYCLE;
                        execute_working_info = 1'b0;
                        rd = rd_i;
                    end
                    `ARITHMETIC_LOGIC_UNIT: begin
                        calculated_result = calculated_alu_result;
                        enable_alu_unit = 1'b0;
                        $display("Arithmetic Logic Unit Finished");
                        $display("-->Execution completed for instruction num %d",i);
                        $display("Result after execution %d",calculated_result);
                        i=i+1;
                        execute1_finished = 1'b1; 
                        STATE = FIRST_CYCLE;
                        execute_working_info = 1'b0;
                        rd = rd_i;
                    end
                    `INTEGER_MULTIPLICATION_UNIT: begin
                        if(finished_integer_multiplication_unit != 1'b1) begin
                            $display("Still integer multiplication");
                            STATE = STALL;
                        end
                        else begin
                            calculated_result = calculated_int_mul_result;
                            enable_integer_multiplication_unit = 1'b0; 
                            integer_multiplication_unit.is_finished = 1'b0;
                            $display("Integer Multiplication Unit Finished for instruction %d",i);
                            $display("-->Execution completed for instruction num %d",i);
                            $display("Result after execution %d",calculated_result);
                            i=i+1;
                            STATE = FIRST_CYCLE;
                            execute_working_info = 1'b0;
                            execute1_finished = 1'b1; 
                            rd = rd_i;
                        end
                    end
                    `INTEGER_DIVISION_UNIT: begin
                        if(finished_integer_division_unit != 1'b1) begin
                            $display("Still integer division");
                            STATE = STALL;
                        end
                        else begin
                            calculated_result = calculated_int_div_result;
                            enable_integer_division_unit = 1'b0; 
                            integer_division_unit.is_finished = 1'b0;
                            $display("Integer Division Unit Finished for instruction %d",i);
                            $display("-->Execution completed for instruction num %d",i);
                            $display("Result after execution %d",calculated_result);
                            i=i+1;
                            execute1_finished = 1'b1; 
                            STATE = FIRST_CYCLE;
                            execute_working_info = 1'b0;
                            rd = rd_i;
                        end
                    end
                    `FLOATING_POINT_UNIT:begin
                    end
                    `BRANCH_RESOLVER_UNIT:begin
                        enable_alu_unit = 1'b0;
                        if(instruction_type_i == `BRANCH_JAL) begin
                            $display("JALLL");
                            calculated_result = calculated_alu_result;
                        end
                        else if(instruction_type_i == `BRANCH_JALR) begin
                            $display("JALRR");
                            calculated_result = calculated_alu_result;    
                            
                            //calculated_branch_result[0] = 1'b0; // crucial                      
                        end
                        enable_branch_resolver_unit = 1'b0;
                        is_branch_address_calculated = 1'b1;
                        $display("Branch Resolver  Unit Finished for instruction %d",i);
                        $display("-->Execution completed for instruction num %d",i);
                        $display("Result after execution %d",calculated_branch_result);
                        i=i+1;
                        execute1_finished = 1'b1; 
                        STATE = FIRST_CYCLE;
                        execute_working_info = 1'b0;
                        other_resources = 1'b0;
                        rd = rd_i;
                    end 
                    `CONTROL_UNIT:begin
                    end
                    `CONTROL_STATUS_UNIT:begin
                    end
                    `ATOMIC_UNIT:begin
                    end
                    `BIT_MANIPULATION_UNIT:begin;
                    end
                    `MEMORY_UNIT: begin
                        if(finished_memory_unit != 1) begin
                            $display("Still in Memory Unit");
                            STATE = STALL;
                        end
                        else begin
                            enable_alu_unit = 1'b0;
                            enable_memory_unit = 1'b0;
                            //mem_op = instruction_type_i[2:0];
                            calculated_result = calculated_memory_unit_result;
                            i=i+1;
                            execute1_finished = 1'b1; 
                            STATE = FIRST_CYCLE;
                            execute_working_info = 1'b0;
                            other_resources = 1'b0;
                            memory_unit.is_finished = 1'b0;
                            rd = rd_i;
                        end
                    end
                endcase
               // rd = rd_i;
                register_selection = register_selection_i;
                unit_type = unit_type_i;
            end
            STALL: begin
                $display("STALL FOR EXECUTE");
                STATE = SECOND_CYCLE;
            end
        endcase
    end
end

assign execute1_finished_o = execute1_finished;       // Assign execute finished
assign calculated_result_o = calculated_result;       // Assign calculated result, goes to memory step
assign execute_working_info_o = execute_working_info;  // Assign execute working info, goes to decode step
assign rd_o = rd;                                      // Assign target register goes to memory step
assign register_selection_o = register_selection;       // Assing register selection, goes to memory step
assign is_branch_address_calculated_o = is_branch_address_calculated; // Assign information of whether branch calculated or not
assign calculated_branch_address_o = calculated_branch_result; // Assign branch address, goes to fetch step
assign write_register_info_o = (register_selection_i == `INTEGER_REGISTER) ? 3'b100 : 
                               (register_selection_i == `FLOAT_REGISTER) ? 3'b010 : 
                               (register_selection_i == `CSR_REGISTER) ? 3'b001 : 
                               3'b000;
endmodule 
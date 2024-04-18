
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
    output wire [2:0] write_register_info_o, // goes to writeback step for writing process
    output wire [31:0] forwarded_data_o
);

reg [3:0] unit_type; // unit type, goes to memory step
reg [31:0] calculated_result; // reg for assign calculated result to calculated result output goes to memory step
reg [4:0] rd;                // target register index, goes to memory step
reg execute_working_info;   //  very important info for stalling goes to decode step
reg [1:0]register_selection;    // register selection info goes to memory step

reg [1:0] register_selection_next;
reg [3:0] unit_type_next;
reg [31:0] calculated_result_next;
reg [4:0] rd_next;

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

wire integer_multiplication_unit_working_info = 1'b0;
wire integer_division_unit_working_info = 1'b0;
wire memory_unit_working_info = 1'b0;

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
integer i = -2; // it is just for debugging the instruction number

localparam FIRST_CYCLE = 3'b000; // State for desiring instruction
localparam SECOND_CYCLE = 3'b001; // State for instruction result
localparam STALL = 3'b010;        // State for stalling the execute step
reg [2:0] STATE = FIRST_CYCLE; // State for the module

always@(*) begin
    register_selection_next = register_selection_i;
    unit_type_next = unit_type_i;
    rd_next = rd_i;
end

always@(*) begin
 $display("@@EXECUTE STAGE Executed instruction num %d ",i);
 $display("----> UNIT : ");
    case(unit_type_i)
        `NONE_UNIT : begin
            $display("NONE UNIT Working");
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            $display("LUI");
         end
        `ARITHMETIC_LOGIC_UNIT: begin
            $display("-->ALU UNIT working");
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
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
            $display("INTEGER MULTIPLICATION UNIT working for instruction %d",i);
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            case(instruction_type_i)
                `INT_MUL: $display("MUL");
                `INT_MULH: $display("MULH");
                `INT_MULHSU: $display("MULHSU");
                `INT_MULHU: $display("MULHU");
            endcase
        end
        `INTEGER_DIVISION_UNIT: begin
            $display("INTEGER DIVISION UNIT working for instruction %d",i);
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            case(instruction_type_i)
                `INT_DIV: $display("DIV");
                `INT_DIVU: $display("DIVU");
                `INT_REM: $display("REM");
                `INT_REMU: $display("REMU");
            endcase
        end
        `FLOATING_POINT_UNIT:begin
            $display("Floating Point Unit working");
        end
        `BRANCH_RESOLVER_UNIT: begin
            enable_branch_resolver_unit = 1'b1;
            if(instruction_type_i == `BRANCH_JAL || `BRANCH_JALR) begin
                $display("Enable otherr");
            end
            $display("Branch Resolver Unit working");
            $display("Program counter ",program_counter_i);
            $display("Immediate",immediate_value_i);
            $display("Rs1 value ",operand1_integer_i);
            $display("Rs2 value ",operand2_integer_i);
        end 
        `CONTROL_UNIT: begin
            $display("Control Unit working");
        end
        `CONTROL_STATUS_UNIT: begin
            $display("Control Status Unit working");
        end
        `ATOMIC_UNIT: begin
            $display("Atomic Unit working");
        end
        `BIT_MANIPULATION_UNIT: begin
            $display("Bit Manipulation Unit working");
        end
        `MEMORY_UNIT: begin
            $display("MEMORY UNIT WORKING");
            $display("-->EX Operand 1 %d",operand1_integer_i);
            $display("-->EX Operand 2 %d",operand2_integer_i);
            $display("-->Executed Instruction :");
            $display("-->Memory address calculation is being done for instruction ",i);
            case(instruction_type_i[2:0])
                `MEM_SW: $display("SW");
                `MEM_LW : $display("LW");
            endcase
        end
    endcase
    execute1_finished = 1'b0;
    i=i+1;
end

always @(*) begin
    execute1_finished = 1'b1; 
    case(unit_type_i)
        `NONE_UNIT : begin
         end
        `ARITHMETIC_LOGIC_UNIT: begin
            enable_alu_unit = 1'b1; 
        end
        `INTEGER_MULTIPLICATION_UNIT: begin
            enable_integer_multiplication_unit = 1'b1;
        end
        `INTEGER_DIVISION_UNIT: begin
            enable_integer_division_unit = 1'b1;
        end
        `FLOATING_POINT_UNIT:begin
            enable_floating_point_unit = 1'b1;
        end
        `BRANCH_RESOLVER_UNIT: begin
            enable_branch_resolver_unit = 1'b1;
            if(instruction_type_i == `BRANCH_JAL || `BRANCH_JALR) begin
                other_resources = 1'b1;
                enable_alu_unit = 1'b1; 
            end
        end 
        `CONTROL_UNIT: begin
            enable_control_unit = 1'b1;
        end
        `CONTROL_STATUS_UNIT: begin
            enable_control_status_unit = 1'b1;
        end
        `ATOMIC_UNIT: begin
            enable_atomic_unit = 1'b1;
        end
        `BIT_MANIPULATION_UNIT: begin
            enable_bit_manipulation_unit = 1'b1;
        end
        `MEMORY_UNIT: begin
            other_resources = 1'b1;
            enable_memory_unit = 1'b1;
        end
    endcase
    
end



always@(posedge clk_i) begin
    if(rst_i) begin
        register_selection_next = 2'b0;
        unit_type_next = 4'b0;
        calculated_result_next = 32'b0;
        rd_next = 5'b0;
        register_selection = 2'b0;
        unit_type = 4'b0;
        calculated_result = 32'b0;
        rd = 5'b0;
        execute_working_info <= 1'b0;
    end
    else begin
            if(execute_working_info_o == 0) begin
                register_selection <= register_selection_next;
                rd <= rd_next;
            end
    end
end

always@(posedge clk_i) begin    
    case(unit_type_i)
        `NONE_UNIT : begin
            calculated_result = immediate_value_i;
            $display("-->LUI LOADED RESULT %d",immediate_value_i);
         end
        `ARITHMETIC_LOGIC_UNIT: begin
            enable_alu_unit = 1'b0; 
            calculated_result = calculated_alu_result;
            $display("--->ALU RESULT %d ",calculated_result);
        end
        `INTEGER_MULTIPLICATION_UNIT: begin
            if(finished_integer_multiplication_unit) begin
               enable_integer_multiplication_unit = 1'b0;
               integer_multiplication_unit.is_finished = 1'b0;
               calculated_result = calculated_int_mul_result;
               $display("--> IM     RESULT %d ",calculated_result);
            end
            else
               $display("INTEGER MULTIPLICATION UNIT STILL WORKING");
        end
        `INTEGER_DIVISION_UNIT: begin
            if(finished_integer_division_unit) begin
               enable_integer_division_unit = 1'b0;
               integer_division_unit.is_finished = 1'b0;
               calculated_result = calculated_int_div_result;
               $display("--> ID RESULT %d ",calculated_result);
            end
            else
               $display("INTEGER DIVISION UNIT STILL WORKING");
        end
        `FLOATING_POINT_UNIT:begin
            enable_floating_point_unit = 1'b1;
        end
        `BRANCH_RESOLVER_UNIT: begin
            enable_branch_resolver_unit = 1'b1;
        end 
        `CONTROL_UNIT: begin
            enable_control_unit = 1'b1;
        end
        `CONTROL_STATUS_UNIT: begin
            enable_control_status_unit = 1'b1;
        end
        `ATOMIC_UNIT: begin
            enable_atomic_unit = 1'b1;
        end
        `BIT_MANIPULATION_UNIT: begin
            enable_bit_manipulation_unit = 1'b1;
        end
        `MEMORY_UNIT: begin
            if(finished_memory_unit) begin
                enable_memory_unit = 1'b0;
                memory_unit.is_finished = 1'b0;
                calculated_result = calculated_memory_unit_result;
                other_resources = 1'b0;
                $display("--> MEM RESULT %h ",calculated_result);
            end
            else
                $display("MEMORY UNIT STILL WORKING");
        end
    endcase 
end

assign integer_multiplication_unit_working_info = (enable_integer_multiplication_unit && finished_integer_multiplication_unit == 1'b0);
assign integer_division_unit_working_info = (enable_integer_division_unit && finished_integer_division_unit == 1'b0);
assign memory_unit_working_info = (enable_memory_unit && finished_memory_unit == 1'b0);

assign execute1_finished_o = execute1_finished;       // Assign execute finished
assign calculated_result_o = calculated_result;       // Assign calculated result, goes to memory step
assign execute_working_info_o =  integer_multiplication_unit_working_info ||
                                 integer_division_unit_working_info ||
                                 memory_unit_working_info;
                                                                  
assign rd_o = rd;                                      // Assign target register goes to memory step
assign register_selection_o = register_selection;       // Assing register selection, goes to memory step
assign is_branch_address_calculated_o = is_branch_address_calculated; // Assign information of whether branch calculated or not
assign calculated_branch_address_o = calculated_branch_result; // Assign branch address, goes to fetch step
assign write_register_info_o = (register_selection == `INTEGER_REGISTER) ? 3'b100 : 
                               (register_selection == `FLOAT_REGISTER) ? 3'b010 : 
                               (register_selection == `CSR_REGISTER) ? 3'b001 : 
                               3'b000;
                               
assign forwarded_data_o = calculated_result;
endmodule 

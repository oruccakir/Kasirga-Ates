

module Execute1Step(
    input wire         clk_i,                                      // clock signal
    input wire         rst_i,                                      // reset signal
    input wire         memory_state_i,                             // durdurmak i?in 
    input wire         branch_predictor_result_i,                  // branch prediction is branched or not
    input wire [31:0]  operand1_integer_i,                         // Operand 1 input comes from decode integer register file
    input wire [31:0]  operand2_integer_i,                         // Operand 2 input comes from decode integer register file or from another calculation logic
    input wire [31:0]  operand1_float_i,                           // Operand 1 input comes from decode float register file
    input wire [31:0]  operand2_float_i,                           // Operand 2 input comes from decode float register file
    input wire [31:0]  operand3_float_i,                           // Operand 3 input comes from decode float register file
    input wire         aq_i,                                       // acquire signal              
    input wire         rl_i,                                       // release signal   
    input wire [4:0]   shamt_i,                                    // shift amount for bit manipulation unit
    input wire [2:0]   rm_i,                                       // rounding mode for floating point unit
    input wire [4:0]   which_operation_i,                          // which operation should be executed
    input wire [31:0]  immediate_i,                                // input : immediate value for calculation of memory address
    input wire [31:0]  pc_i,                                       // input : program counter for calculation of memory address
    input wire         enable_integer_multiplication_unit_i,       // enable signal for integer multiplication unit
    input wire         enable_integer_division_unit_i,             // enable signal for integer division unit 
    input wire         enable_floating_point_unit_i,               // enable signal for floating point unit
    input wire         enable_bit_manipulation_unit_i,               // enable signal for bit manipulation unit
    input wire         enable_control_status_unit_i,               // enable signal for control status unit
    input wire         enable_memory_unit_i,                       // enable for memory operations goes to memory stage
    input wire         enable_atomic_unit_i,                       // enable signal for atomic unit  
    input wire         enable_arithmetic_logic_unit_i,
    input wire [1:0]   register_type_selection_i,                  // destination register: floating register or integer register
    input wire [4:0]   rd_i,                                      // Destination register input from decode step, goes to memory step for write back
    input wire [31:0]  mem_stored_data_i,                       // input register value to store in memory    
    output wire        enable_atomic_unit_o,
    output wire        enable_memory_unit_o,
    output wire [4:0]  rd_o,                                      // Destination register output goes to memory step for write back
    output wire [31:0] mem_stored_data_o,                          // data to be written to memory
    output wire [31:0] calculated_memory_address_o,                // memory address to be read or written
    output wire [31:0] calculated_result_o,                        // calculated result output, goes to memory step
    output wire [ 1:0] register_type_selection_o,                  // output : transfer from decode to memory 
    output wire        is_branched_o,                             // branched or not
    output wire [31:0] branched_address_o,                        // branched address to be fetched right instruction
    output wire        is_branched_address_valid_o,               // branch address valid
    output wire        is_branch_predictor_true_o,                  // is branch predictor successfull
    output wire [31:0] forwarded_data_o,    
    output wire [4:0]  forwarded_rd_o,
    output wire        execute_state_o,
    output wire [2:0]  memOp_o
);
/*
 Module states
*/
wire int_mul_unit_state;
wire int_div_unit_state;
wire float_point_unit_state;
wire control_status_unit_state;
wire bit_manip_unit_state;
wire execute_state;


reg [4:0] rd_next;
reg [4:0] rd;
reg [31:0] mem_stored_data;
reg [31:0] calculated_result;
reg [31:0] calculated_memory_address;
reg [2:0]  memOp;
reg [2:0]  memOp_next;
reg [1:0]  register_type_selection;
reg [1:0]  register_type_selection_next;
reg [31:0] mem_stored_data_next;
reg enable_atomic_unit_next;
reg enable_memory_unit_next;
reg enable_memory_unit;
reg enable_atomic_unit;



wire [31:0] calculated_result_alu;
ArithmeticLogicUnit alu(
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .aluOp_i(which_operation_i),
    .result_o(calculated_result_alu)
);

// Integer Multiplication Unit module 
wire finished_integer_multiplication_unit;
wire [31:0] calculated_result_mul;
IntegerMultiplicationUnit imu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_integer_multiplication_unit_i(enable_integer_multiplication_unit_i),
    .mulOp_i(which_operation_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_result_mul),
    .finished_o(finished_integer_multiplication_unit)
);


// Integer Division Unit module;
wire finished_integer_division_unit;
wire [31:0] calculated_int_div_result;
IntegerDivisionUnit idu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_integer_division_unit_i(enable_integer_division_unit_i),
    .divOp_i(which_operation_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .result_o(calculated_int_div_result),
    .finished_o(finished_integer_division_unit)
);


// Floating Point Unit module
wire finished_floating_point_unit;
wire [31:0] calculated_fpu_result;
FloatingPointUnit fpu(  // sadece word okur ve yazar
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_floating_point_unit_i(enable_floating_point_unit_i),
    .float_operation_i(which_operation_i),
    .operand1_i(operand1_float_i),
    .operand2_i(operand2_float_i),
    .operand3_i(operand3_float_i),
    .rm_i(rm_i),
    .fpu_result_o(calculated_fpu_result),
    .finished_o(finished_floating_point_unit)
);




// Bit Manipulation Unit module
wire finished_bit_manipulation_unit;
wire [31:0] calculated_bmu_result;
BitManipulationUnit bmu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_bit_manipulation_unit_i(enable_bit_manipulation_unit_i),
    .operand1_i(operand1_integer_i),
    .operand2_i(operand2_integer_i),
    .shamt_i(shamt_i),
    .bmuOp_i(which_operation_i),
    .result_o(calculated_bmu_result),
    .finished_o(finished_bit_manipulation_unit)
);



// Branch Resolver Unit module
wire is_branched;
wire [31:0] branched_address;
wire is_branched_address_valid;
wire is_branch_predictor_true;
BranchResolverUnit bru(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .branch_instruction_selection_i(which_operation_i),
    .branch_predictor_result_i(branch_predictor_result_i),
    .operand1_integer_i(operand1_integer_i),
    .operand2_integer_i(operand2_integer_i),
    .operand1_float_i(operand1_float_i),
    .operand2_float_i(operand2_float_i),
    .operand3_float_i(operand3_float_i),
    .pc_i(pc_i),
    .immediate_i(immediate_i),
    .is_branched_o(is_branched),
    .branched_address_o(branched_address),
    .is_branched_address_valid_o(is_branched_address_valid),
    .is_branch_predictor_true_o(is_branch_predictor_true)
);


// Control Status Unit module
wire finished_control_status_unit;
ControlStatusUnit csu(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .enable_control_status_unit_i(enable_control_status_unit_i),
    .finished_o(finished_control_status_unit)
);

always@(*) begin
    memOp_next =  which_operation_i[2:0]; 
    register_type_selection_next = register_type_selection_i;
    mem_stored_data_next = mem_stored_data_i;
    rd_next  = rd_i;
    enable_memory_unit_next = enable_memory_unit_i;
    enable_atomic_unit_next = enable_atomic_unit_i;
end


always@(posedge clk_i) begin
    if(rst_i) begin
        enable_atomic_unit_next<=1'b0;
        enable_memory_unit_next<=1'b0;
        enable_atomic_unit<=1'b0;
        enable_memory_unit<=1'b0;
        rd_next <= 5'b0;
        rd <= 5'b0;
        mem_stored_data <= 32'b0;
        mem_stored_data_next <= 32'b0;
        register_type_selection_next <= `NONE_REGISTER;
        memOp_next <= 3'b0;
        memOp <= 3'b0;
        calculated_memory_address <= 32'b0;
        register_type_selection<=`NONE_REGISTER;
        calculated_result<=32'b0;
    end else begin
        if(execute_state == `COMPLETED) begin
            memOp <= memOp_next;
            register_type_selection <= register_type_selection_next;
            mem_stored_data <= mem_stored_data_next;
            rd <= rd_next;
            enable_memory_unit <= enable_memory_unit_next;
            enable_atomic_unit <= enable_atomic_unit_next;
        end
    end
end

always@(posedge clk_i) begin

    if(execute_state == `COMPLETED) begin  //memory degisince ~execute_stall_required_i cevir
        calculated_memory_address <= calculated_result_alu;
        if(enable_arithmetic_logic_unit_i)begin
            calculated_result<=calculated_result_alu;
        end
        else if (enable_integer_multiplication_unit_i && finished_integer_multiplication_unit) begin
            calculated_result<=calculated_result_mul;
            imu.finished_o<=1'b0;
        end 
        else if (enable_integer_division_unit_i && finished_integer_division_unit) begin
            calculated_result<=calculated_int_div_result;
            idu.finished_o<=1'b0;
        end
        else if (enable_floating_point_unit_i && finished_floating_point_unit) begin
                calculated_result<= calculated_fpu_result;
                fpu.finished_o<=1'b0;         
        end
        else if (enable_bit_manipulation_unit_i && finished_bit_manipulation_unit) begin
            calculated_result<= calculated_bmu_result;
            bmu.finished_o<=1'b0;      
        end  
        else if (enable_control_status_unit_i && finished_control_status_unit) begin
            csu.finished_o<='b0;
        end 
    end
end

assign int_mul_unit_state =  enable_integer_multiplication_unit_i && ~finished_integer_multiplication_unit;
assign int_div_unit_state =  enable_integer_division_unit_i && ~finished_integer_division_unit;
assign float_point_unit_state = enable_floating_point_unit_i && ~finished_floating_point_unit;
assign control_status_unit_state = enable_control_status_unit_i && ~finished_control_status_unit;
assign bit_manip_unit_state = enable_bit_manipulation_unit_i && ~finished_bit_manipulation_unit;

assign execute_state = memory_state_i ||
                              int_mul_unit_state ||
                              int_div_unit_state ||
                              float_point_unit_state ||
                              control_status_unit_state ||
                              bit_manip_unit_state;
                 
assign enable_memory_unit_o = enable_memory_unit;
assign enable_atomic_unit_o = enable_atomic_unit;
assign rd_o = rd;
assign mem_stored_data_o = mem_stored_data;
assign register_type_selection_o = register_type_selection;
assign calculated_result_o = calculated_result;
assign execute_state_o = execute_state;
assign calculated_memory_address_o = calculated_memory_address;
assign is_branched_o=is_branched;
assign branched_address_o=branched_address;
assign is_branched_address_valid_o=is_branched_address_valid;
assign is_branch_predictor_true_o=is_branch_predictor_true;
assign forwarded_data_o = calculated_result;                                                                                                               // Assign forwarded data, goes to decode stage
assign forwarded_rd_o = rd_o; 
assign memOp_o = memOp;    
endmodule

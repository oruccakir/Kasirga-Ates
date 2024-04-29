from imports import *
BRANCH_BEQ    = 0                   
BRANCH_BNE    = 1                  
BRANCH_BLT    = 2                  
BRANCH_BGE    = 3                  
BRANCH_BLTU   = 4                  
BRANCH_BGEU   = 5                  
BRANCH_JAL    = 6                  
BRANCH_JALR   = 7

BRANCH_TAKEN = 1
BRANCH_NOT_TAKEN = 0

@cocotb.test()
async def test_branch_beq(branch_resolver):
    branch_resolver.instruction_type_i.value = BRANCH_BEQ
    branch_resolver.enable_i.value = 1
    number_of_tests = 1000
    for test in range(number_of_tests):
        program_counter = int(random.random()*2**31)
        immeadiate_value = int(random.random()*2**31)
        operand1 = 12#int(random.random()*2**31)
        operand2 = 10#int(random.random()*2**31)
        branch_resolver.program_counter_i.value = program_counter
        branch_resolver.immediate_value_i.value = immeadiate_value
        branch_resolver.operand1_i.value = int(operand1)
        branch_resolver.operand2_i.value = int(operand2)
        address = branch_resolver.result_o.value
        branch_info = branch_resolver.branch_info_o.value
        assert1 = operand1 == operand2
        await Timer(2,units="ns")
        assert(assert1,f"Expected Result = {address}   Operand1 {branch_resolver.operand1_i.value} Operand2  {branch_resolver.operand2_i.value} Immediate {branch_resolver.immediate_value_i.value }\nModule Output = { branch_info == BRANCH_TAKEN}")
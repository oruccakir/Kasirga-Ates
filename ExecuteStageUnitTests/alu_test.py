# Purpose: To test the ALU module
from imports import *
ALU_ADD      =           0
ALU_SUB      =            1
ALU_XOR     =           2
ALU_OR      =            3
ALU_AND     =            4
ALU_SLL      =           5
ALU_SRL    =            6
ALU_SRA     =            7
ALU_SLT      =           8
ALU_SLTU      =          9
ALU_ADDI        =        10
ALU_SLTI         =       11
ALU_SLTIU         =      12
ALU_XORI        =        13
ALU_ORI         =       14
ALU_ANDI         =      15
ALU_SLLI          =      16
ALU_SRLI          =      17
ALU_SRAI          =      18

@cocotb.test()
async def test_alu_addition(alu):
    number_of_tests = 1000
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**31)
        operand2  = int(random.random()*2**31)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        alu.enable_i.value = 1
        alu.other_resources_i.value = 0
        alu.aluOp_i.value = ALU_ADD
        result = operand1 + operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {result}\nModule Output = {alu.result_o.value}"

"""
@cocotb.test()
async def test_alu_subtraction(alu):
    number_of_tests = 1000
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**31)
        operand2  = int(random.random()*2**31)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        alu.enable_i.value = 1
        alu.other_resources_i.value = 0
        alu.aluOp_i.value = 1
        result = operand1 - operand2

        module_output = int(alu.result_o.value.binstr, 2)  # Get the binary string of the output
        if module_output >= 2**31:  # Adjust if the number is negative
            module_output -= 2**32
        print("Beklenen : ",result, " Modul : ",alu.result_o.value)
        await Timer(2,units="ns")
        assert(result == module_output),f"Expected Result = {result}    {operand1} -  {operand2}\nModule Output = {module_output}"
"""
@cocotb.test()
async def test_alu_and(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_AND
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**32)
        operand2  = int(random.random()*2**32)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 & operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"

@cocotb.test()
async def test_alu_or(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_OR
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**32)
        operand2  = int(random.random()*2**32)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 | operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"

@cocotb.test()
async def test_alu_xor(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_XOR
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**32)
        operand2  = int(random.random()*2**32)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 ^ operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"

@cocotb.test()
async def test_alu_sll(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_SLL
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**32)
        operand2  = int(random.random()*2**5)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = (operand1 << operand2) % 2**32
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"


@cocotb.test()
async def test_alu_srl(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_SRL
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**32)
        operand2  = int(random.random()*2**5)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 >> operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"

@cocotb.test()
async def test_alu_sra(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_SRA
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**31)
        operand2  = int(random.random()*2**5)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 >> (operand2 % 2**5)
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"

@cocotb.test()
async def test_alu_slt(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_SLT
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**31)
        operand2  = int(random.random()*2**31)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 < operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"


@cocotb.test()
async def test_alu_sltu(alu):
    number_of_tests = 1000
    alu.enable_i.value = 1
    alu.other_resources_i.value = 0
    alu.aluOp_i.value = ALU_SLTU
    for test_idx in range(number_of_tests):
        operand1  = int(random.random()*2**32)
        operand2  = int(random.random()*2**32)
        alu.operand1_i.value = operand1
        alu.operand2_i.value = operand2
        result = operand1 < operand2
        await Timer(2,units="ns")
        assert(result == alu.result_o.value),f"Expected Result = {bin(result)}    {operand1} -  {operand2}\nModule Output = {alu.result_o.value}"
import cocotb
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory
import cocotb
from cocotb.triggers import Timer
import random
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
"""
@cocotb.test()
async def test_alu_addition(dut):
    test_sayisi = 1000
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**31)
        deger2  = int(random.random()*2**31)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        dut.enable_i.value = 1
        dut.other_resources_i.value = 0
        dut.aluOp_i.value = ALU_ADD
        sonuc = deger1 + deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {sonuc}\nModul ciktisi = {dut.result_o.value}"
"""
"""
@cocotb.test()
async def test_alu_subtraction(dut):
    test_sayisi = 1000
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**31)
        deger2  = int(random.random()*2**31)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        dut.enable_i.value = 1
        dut.other_resources_i.value = 0
        dut.aluOp_i.value = 1
        sonuc = deger1 - deger2

        module_output = int(dut.result_o.value.binstr, 2)  # Get the binary string of the output
        if module_output >= 2**31:  # Adjust if the number is negative
            module_output -= 2**32
        print("Beklenen : ",sonuc, " Modul : ",dut.result_o.value)
        await Timer(2,units="ns")
        assert(sonuc == module_output),f"Beklenen sonuc = {sonuc}    {deger1} -  {deger2}\nModul ciktisi = {module_output}"
"""
@cocotb.test()
async def test_alu_and(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_AND
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**32)
        deger2  = int(random.random()*2**32)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 & deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"

@cocotb.test()
async def test_alu_or(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_OR
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**32)
        deger2  = int(random.random()*2**32)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 | deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"

@cocotb.test()
async def test_alu_xor(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_XOR
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**32)
        deger2  = int(random.random()*2**32)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 ^ deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"

@cocotb.test()
async def test_alu_sll(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_SLL
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**32)
        deger2  = int(random.random()*2**5)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = (deger1 << deger2) % 2**32
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"


@cocotb.test()
async def test_alu_srl(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_SRL
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**32)
        deger2  = int(random.random()*2**5)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 >> deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"

@cocotb.test()
async def test_alu_sra(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_SRA
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**31)
        deger2  = int(random.random()*2**5)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 >> (deger2 % 2**5)
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"

@cocotb.test()
async def test_alu_slt(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_SLT
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**31)
        deger2  = int(random.random()*2**31)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 < deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"


@cocotb.test()
async def test_alu_sltu(dut):
    test_sayisi = 1000
    dut.enable_i.value = 1
    dut.other_resources_i.value = 0
    dut.aluOp_i.value = ALU_SLTU
    for test_idx in range(test_sayisi):
        deger1  = int(random.random()*2**32)
        deger2  = int(random.random()*2**32)
        dut.operand1_i.value = deger1
        dut.operand2_i.value = deger2
        sonuc = deger1 < deger2
        await Timer(2,units="ns")
        assert(sonuc == dut.result_o.value),f"Beklenen sonuc = {bin(sonuc)}    {deger1} -  {deger2}\nModul ciktisi = {dut.result_o.value}"
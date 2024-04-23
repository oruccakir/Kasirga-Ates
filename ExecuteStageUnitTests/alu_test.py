import cocotb
from cocotb.triggers import RisingEdge
from cocotb.regression import TestFactory

@cocotb.coroutine
async def test_alu(dut):
    # Test inputs
    dut.operand1_i.value = 10
    dut.operand2_i.value = 5
    dut.enable_i.value = 1
    dut.aluOp_i.value = 0  # Örnek bir işlem kodu
    await RisingEdge(dut.clock)
    assert dut.result_o.value == 15, "ALU Addition result error!"

factory = TestFactory(test_alu)
factory.generate_tests()

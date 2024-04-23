# Makefile
TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(shell pwd)/ArithmeticLogicUnit.v
TOPLEVEL = ArithmeticLogicUnit
MODULE = alu_test  # Python test modülü adı
SIM = icarus  # Kullanılacak simülatör

include $(shell cocotb-config --makefiles)/Makefile.sim

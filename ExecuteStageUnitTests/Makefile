# Makefile
TOPLEVEL_LANG = verilog
VERILOG_SOURCES += ../ExecuteStageUnitTests/*.v
VERILOG_SOURCES += ../ExecuteStageUnitTests/*.vh

IVERILOG_OPTS = -I ../ExecuteStageUnitTests/*.vh

TOPLEVEL = ArithmeticLogicUnit
MODULE = alu_test  # Python test modülü adı
SIM = icarus  # Kullanılacak simülatör

include $(shell cocotb-config --makefiles)/Makefile.sim

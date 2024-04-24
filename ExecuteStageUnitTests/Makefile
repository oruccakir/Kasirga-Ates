# Makefile
SOURCE = ../KasirgaVerilogCopy/KasirgaVerilogCopy.srcs/sources_1/new
TOPLEVEL_LANG = verilog

VERILOG_INCLUDE_DIRS = $(SOURCE)

VERILOG_SOURCES += $(SOURCE)/ArithmeticLogicUnit.v \
                $(SOURCE)/RippleCarryAdder32.v \
                $(SOURCE)/wallace.v \
                $(SOURCE)/definitions.vh \
                 



TOPLEVEL = ArithmeticLogicUnit
MODULE = alu_test  # Python test modülü adı
SIM = icarus  # Kullanılacak simülatör

include $(shell cocotb-config --makefiles)/Makefile.sim

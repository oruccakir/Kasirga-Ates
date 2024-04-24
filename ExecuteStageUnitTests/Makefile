# Makefile
TOPLEVEL_LANG = verilog
SIM = icarus  # Kullanılacak simülatör
SOURCE = ../KasirgaVerilogCopy/KasirgaVerilogCopy.srcs/sources_1/new
MODULE := branch_resolver_test
#TOPLEVEL := BranchResolverUnit
VERILOG_INCLUDE_DIRS = $(SOURCE)
VERILOG_SOURCES +=$(SOURCE)/ArithmeticLogicUnit.v \
                $(SOURCE)/BranchResolverUnit.v \
                $(SOURCE)/RippleCarryAdder32.v \
                $(SOURCE)/wallace.v \
                $(SOURCE)/definitions.vh



ifeq ($(MODULE), branch_resolver_test)
	TOPLEVEL        := BranchResolverUnit
else ifeq ($(MODULE), alu_test)
	TOPLEVEL        := ArithmeticLogicUnit
else
    $(error A module was not provided)
endif


export RANDOM_SEED := 123456789
include $(shell cocotb-config --makefiles)/Makefile.sim
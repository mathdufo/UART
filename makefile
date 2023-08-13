SIM = icarus
TOPLEVEL_LANG = verilog

VERILOG_SOURCES += $(wildcard *.v)

TOPLEVEL = uart

MODULE = test_uart

include $(shell cocotb-config --makefiles)/Makefile.sim
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(wildcard ../rtl/*.v)  uart_loop.v

TOPLEVEL = uart_loop

MODULE = test_uart

include $(shell cocotb-config --makefiles)/Makefile.sim
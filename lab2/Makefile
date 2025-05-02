LAB_NAME := lab2

VSRCS := $(wildcard src/*)

SUBMIT_VSRCS := src/fifo.sv \
				src/uart_transmitter.sv \
				src/uart.sv \
				src/top.sv

SUBMIT_FILES := $(SUBMIT_VSRCS) \
				docs/report.pdf

include ../scripts/common.mk

.PRECIOUS: build/tb_%.vcd # don't delete .vcd files

tb_%: build/tb_%.vcd
	@echo "@@@@@@@@ run $@ finished @@@@@@@@"

build/tb_%.vcd: build/tb_%
	@echo "@@@@@@@@ run $(notdir $<) ,,,,,,,, @@@@@@@@"
	@cd build && $(VVP) $(notdir $<)

build/tb_uart_transmitter: src/uart_transmitter.sv sim/tb_uart_transmitter.sv $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_uart2uart: src/uart_transmitter.sv src/uart_receiver.sv src/uart.sv sim/tb_uart2uart.sv $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_fifo: src/fifo.sv sim/tb_fifo.sv $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_simple_echo: sim/tb_simple_echo.sv $(VSRCS) $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_echo: sim/tb_echo.sv $(VSRCS) $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

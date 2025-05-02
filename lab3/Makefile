LAB_NAME := lab3

VSRCS := $(shell find src -type f -name '*.sv')

SUBMIT_VSRCS := src/core/alu.sv \
				src/core/register_file.sv \
				src/core/immediate_generator.sv

SUBMIT_FILES := $(SUBMIT_VSRCS) \
				docs/report.pdf

include ../scripts/common.mk

IVERILOG_OPTS += -I src/core -I sim # to search verilog headers

.PRECIOUS: build/tb_%.fst # don't delete .fst files

tb_%: build/tb_%.fst
	@echo "@@@@@@@@ run $@ finished @@@@@@@@"

build/tb_%.fst: build/tb_%
	@echo "@@@@@@@@ run $(notdir $<) ,,,,,,,, @@@@@@@@"
	@cd build && $(VVP) $(notdir $<)

build/tb_alu: src/core/alu.sv sim/tb_alu.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_register_file: src/core/register_file.sv sim/tb_register_file.sv $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_immediate_generator: src/core/immediate_generator.sv sim/tb_immediate_generator.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_controller: src/core/controller.sv sim/tb_controller.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_asm: sim/tb_asm.sv $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_cpu: sim/tb_cpu.sv $(VSRCS) $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^

build/tb_hello_world: sim/tb_hello_world.sv $(VSRCS) $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(BUILD_DIR)
	@$(IVERILOG) $(IVERILOG_OPTS) -o $@ $^
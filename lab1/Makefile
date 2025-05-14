LAB_NAME := lab1

VSRCS := src/seven_segments.sv \
		 src/display_controller.sv \
		 src/counter.sv \
		 src/synchronizer.sv \
		 src/debouncer.sv \
		 src/edge_detector.sv \
		 src/top.sv

# SUBMIT_FILES := $(VSRCS) \
# 				docs/report.pdf

SUBMIT_FILES := $(VSRCS)

include ../scripts/common.mk

tb_seven_segments: build/tb_seven_segments
	@cd build && ./$@

build/tb_seven_segments: src/seven_segments.sv sim/tb_seven_segments.cpp $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) \
			--top-module SevenSegments $(abspath $^) \
			$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
			-o $(abspath $@)

tb_counter: build/tb_counter
	@cd build && ./$@

build/tb_counter: src/counter.sv sim/tb_counter.cpp $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) \
			--top-module Counter $(abspath $^) \
			$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
			-o $(abspath $@)

tb_debouncer: build/tb_debouncer
	@cd build && ./$@

build/tb_debouncer: src/debouncer.sv sim/tb_debouncer.cpp $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) \
			--top-module Debouncer $(abspath $^) \
			$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
			-o $(abspath $@)

tb_synchronizer: build/tb_synchronizer
	@cd build && ./$@

build/tb_synchronizer: src/synchronizer.sv sim/tb_synchronizer.cpp $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) \
			--top-module Synchronizer $(abspath $^) \
			$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
			-o $(abspath $@)

tb_edge_detector: build/tb_edge_detector
	@cd build && ./$@

build/tb_edge_detector: src/edge_detector.sv sim/tb_edge_detector.cpp $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) \
			--top-module EdgeDetector $(abspath $^) \
			$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
			-o $(abspath $@)

tb_top: build/tb_top
	@cd build && ./$@

build/tb_top: $(VSRCS) sim/tb_top.cpp $(INCLUDE_DIR)/utils.sv
	@mkdir -p $(OBJ_DIR)
	@$(VERILATOR) $(VERILATOR_FLAGS) \
			--top-module top $(abspath $^) \
			$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
			-o $(abspath $@)

.PHONY: tb_seven_segments tb_counter tb_debouncer tb_synchronizer tb_edge_detector

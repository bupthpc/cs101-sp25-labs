STUDENT_ID  := 2024000000
HANDIN      := $(LAB_NAME)-$(STUDENT_ID).zip
SERVER_ADDR := 10.112.97.234:5000

WORK_DIR  := $(shell pwd)
BUILD_DIR := $(WORK_DIR)/build
OBJ_DIR   := $(BUILD_DIR)/obj_dir

INCLUDE_DIR := $(WORK_DIR)/../include

ifeq ($(VERILATOR_ROOT),)
VERILATOR := verilator
else
export VERILATOR_ROOT
VERILATOR := $(VERILATOR_ROOT)/bin/verilator
endif

VERILATOR_FLAGS := -cc --exe \
                   -MMD \
                   -x-assign fast \
                   -Wall \
                   --trace \
                   --noassert \
                   --build -j 0 \
                   --Mdir $(OBJ_DIR)

VERILATOR_FLAGS += -I$(INCLUDE_DIR)
VERILATOR_FLAGS += -Wno-DECLFILENAME

CXXFLAGS := -I$(INCLUDE_DIR)

IVERILOG                := iverilog
IVERILOG_OPTS           := -g2012 -gassertions -Wall -Wno-timescale
VVP                     := vvp


grade:
	$(MAKE) clean
	@$(WORK_DIR)/grade.py

$(HANDIN): $(SUBMIT_FILES)
	@zip $(HANDIN) $(SUBMIT_FILES)

tarball: $(HANDIN)

submit: $(HANDIN)
	curl -F "file=@$(HANDIN)" -F "student_id=$(STUDENT_ID)" http://$(SERVER_ADDR)/api/v1/submit

clean:
	-@rm -rf $(BUILD_DIR) $(HANDIN)

.PHONY: grade tarball submit clean

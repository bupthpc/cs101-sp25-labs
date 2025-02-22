#include <iostream>
#include <bitset>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VEdgeDetector.h"
#include "utils.h"

#define CLOCK_PERIOD 10
#define TIMEOUT      1000

#define TRACE() do { \
    dut->eval(); \
    tfp->dump(contextp->time()); \
    contextp->timeInc(CLOCK_PERIOD/2); \
  } while (0)

int main(int argc, char** argv) {
  const auto contextp = std::make_unique<VerilatedContext>();
  contextp->commandArgs(argc, argv);
  contextp->traceEverOn(true);

  auto dut = std::make_unique<VEdgeDetector>(contextp.get());
  auto tfp = std::make_unique<VerilatedVcdC>();
  dut->trace(tfp.get(), 99);
  tfp->open("edge_detector.vcd");

  bool success = false;
  const int start = 6;
  const int end = 13;
  bool edge_detected = false;
  int detected_time;
  
  dut->serial_in = 0;

  for(int i = 0; ; ++i) {
    if (i * CLOCK_PERIOD >= TIMEOUT) {
      ERROR("Timeout\n");
      goto failure;
    }

    if (i == start) {
      dut->serial_in = 1;
    } else if (i == end * 2) {
      dut->serial_in = 0;
    }

    // negedge
    dut->clk = 0;
    TRACE();

    // posedge
    dut->clk = 1;
    TRACE();

    if (!edge_detected && dut->edge_detect_pulse) {
      edge_detected = true;
      detected_time = i;
      continue;
    }

    if (edge_detected && !dut->edge_detect_pulse && i == detected_time + 1) {
      break;
    }
  }

  SUCCESS("==== tb_edge_detector passed ====\n");
  success = true;

failure:
  tfp->close();
  return success ? 0 : 1;
}

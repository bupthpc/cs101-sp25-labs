#include <iostream>
#include <bitset>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VSynchronizer.h"
#include "utils.h"

#define CLOCK_PERIOD 8

#define TRACE(callback, ...) do { \
    dut->eval(); \
    tfp->dump(contextp->time()); \
    contextp->timeInc(CLOCK_PERIOD/2); \
    callback(__VA_ARGS__); \
  } while (0)

#define TICK(n, callback, ...) do { \
    for (int i = 0; i < n; i++) { \
      dut->clk = 0; TRACE(callback, ## __VA_ARGS__); \
      dut->clk = 1; TRACE(callback, ## __VA_ARGS__); \
    } \
  } while (0)

#define ASSERT_LOW(fmt, ...) do { \
    if (dut->sync_out) { \
      ERROR(fmt, ## __VA_ARGS__); \
      goto failure; \
    } \
  } while (0)

#define ASSERT_HIGH(fmt, ...) do { \
    if (!dut->sync_out) { \
      ERROR(fmt, ## __VA_ARGS__); \
      goto failure; \
    } \
  } while (0)

void empty() {}

int main(int argc, char** argv) {
  const auto contextp = std::make_unique<VerilatedContext>();
  contextp->commandArgs(argc, argv);
  contextp->traceEverOn(true);

  auto dut = std::make_unique<VSynchronizer>(contextp.get());
  auto tfp = std::make_unique<VerilatedVcdC>();
  dut->trace(tfp.get(), 99);
  tfp->open("synchronizer.vcd");

  bool success = false;

  dut->async_in = 0;
  TICK(2, ASSERT_LOW, "Error in first 2 cycles\n");

  dut->async_in = 1;
  TICK(1, ASSERT_LOW, "Error in cycle 3\n");

  dut->async_in = 0;
  dut->clk = 0; TRACE(ASSERT_LOW, "Error at negedge of cycle 3\n");
  dut->clk = 1; TRACE(ASSERT_HIGH, "Error at posedge of cycle 4\n");
  dut->clk = 0; TRACE(ASSERT_HIGH, "Error at negedge of cycle 4\n");
  dut->clk = 1; TRACE(ASSERT_LOW, "Error at posedge of cycle 5\n");
  TICK(2, ASSERT_LOW, "Error in cycles 6-7\n");

  SUCCESS("==== tb_synchronizer passed ====\n");
  success = true;

failure:
  tfp->close();
  return success ? 0 : 1;
}

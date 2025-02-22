#include <iostream>
#include <bitset>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VDebouncer.h"
#include "utils.h"

#define CLOCK_PERIOD 8
#define SAMPLE_CNT_MAX 10
#define PULSE_CNT_MAX 4

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
    if (dut->debounced_signal) { \
      ERROR(fmt, ## __VA_ARGS__); \
      goto failure; \
    } \
  } while (0)

#define ASSERT_HIGH(fmt, ...) do { \
    if (!dut->debounced_signal) { \
      ERROR(fmt, ## __VA_ARGS__); \
      goto failure; \
    } \
  } while (0)

void empty() {}

int main(int argc, char** argv) {
  const auto contextp = std::make_unique<VerilatedContext>();
  contextp->commandArgs(argc, argv);
  contextp->traceEverOn(true);

  auto dut = std::make_unique<VDebouncer>(contextp.get());
  auto tfp = std::make_unique<VerilatedVcdC>();
  dut->trace(tfp.get(), 99);
  tfp->open("debouncer.vcd");

  bool success = false;

  // initial test
  ASSERT_LOW("Initial debounced signal should be low\n");

  // filter test
  dut->glitchy_signal = 1;
  TICK(SAMPLE_CNT_MAX * (PULSE_CNT_MAX - 1), ASSERT_LOW,
       "Debouncer should filter out glitches\n");
  dut->glitchy_signal = 0;
  TICK(1, empty);

  // pulse test
  dut->glitchy_signal = 1;
  TICK(SAMPLE_CNT_MAX * (PULSE_CNT_MAX + 1), empty);

  TICK(SAMPLE_CNT_MAX * 3, ASSERT_HIGH,
       "Debounced signal should stay high when counter saturates\n");

  SUCCESS("==== tb_debouncer passed ====\n");
  success = true;

failure:
  tfp->close();
  return success ? 0 : 1;
}

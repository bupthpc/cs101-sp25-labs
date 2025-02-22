#include <iostream>
#include <bitset>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VCounter.h"
#include "utils.h"

#define CLOCK_PERIOD 10
#define TIMEOUT      100000

#define TRACE() do { \
    dut->eval(); \
    tfp->dump(contextp->time()); \
    contextp->timeInc(CLOCK_PERIOD/2); \
  } while (0)

#define TICK(n) do { \
    for (int i = 0; i < n; i++) { \
      dut->clk = 0; TRACE(); \
      dut->clk = 1; TRACE(); \
    } \
  } while (0)

#define RESET(n) do { \
    dut->rst = 1; \
    TICK(n); \
    dut->rst = 0; \
  } while (0)

#define CLOCK_EN(n) do { \
    dut->en = 1; \
    TICK(n); \
    dut->en = 0; \
  } while (0)

#define BCD2INT(bcd, width) ({ \
    uint64_t res = 0; \
    int n = (width - 1) / 4; \
    for (int i = n; i >= 0; --i) { \
      res = res * 10 + ((bcd >> (i * 4)) & 0xF); \
    } \
    res; \
  })

int main(int argc, char** argv) {
  const auto contextp = std::make_unique<VerilatedContext>();
  contextp->commandArgs(argc, argv);
  contextp->traceEverOn(true);

  auto dut = std::make_unique<VCounter>(contextp.get());
  auto tfp = std::make_unique<VerilatedVcdC>();
  dut->trace(tfp.get(), 99);
  tfp->open("counter.vcd");

  RESET(10);

  bool success = false;
  uint64_t expected_output = 0;
  uint64_t actual_output;
  int tmp;

  // check reset
  if (dut->out != 0) {
    std::cout << "Expected output: " << 0 << " | "
              << "Actual output: " << dut->out << '\n';
    ERROR("Test failed for reset\n");
    goto failure;
  }

  while (contextp->time() < TIMEOUT) {
    if (rand() % 2) {
      tmp = rand() % 10 + 1;
      CLOCK_EN(tmp);
      expected_output += tmp;
    } else {
      tmp = rand() % 10 + 1;
      TICK(tmp);
    }

    actual_output = BCD2INT(dut->out, 32);

    INFO("[Cycle %4ld] ", contextp->time() / CLOCK_PERIOD);

    std::cout << "Expected Output: " << expected_output << " | "
              << "Actual Output: " << actual_output << '\n';

    if (expected_output != actual_output) {
      ERROR("Test failed for output mismatch\n");
      goto failure;
    }
  }

  SUCCESS("==== tb_counter passed ====\n");
  success = true;

failure:
  tfp->close();
  return success ? 0 : 1;
}
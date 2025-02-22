#include <iostream>
#include <bitset>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"
#include "utils.h"

#define CLOCK_PERIOD 10
#define PRESS_TIME   100000

const int segments[] = {
    0b0000001, // 0
    0b1001111, // 1
    0b0010010, // 2
    0b0000110, // 3
    0b1001100, // 4
    0b0100100, // 5
    0b0100000, // 6
    0b0001111, // 7
    0b0000000, // 8
    0b0000100  // 9
};

#define DIGIT2SEG(i) segments[i]

#define TRACE() do { \
    dut->eval(); \
    contextp->timeInc(CLOCK_PERIOD/2); \
  } while (0)

#define TICK(n) do { \
    for (int i = 0; i < n; i++) { \
      dut->CLK100MHZ = 0; TRACE(); \
      dut->CLK100MHZ = 1; TRACE(); \
    } \
  } while (0)
    
#define RESET(n) do { \
    dut->BTNC = 1; \
    TICK(n); \
    dut->BTNC = 0; \
  } while (0)

#define PRESS() do { \
    dut->BTNU = 1; \
    TICK(PRESS_TIME); \
    dut->BTNU = 0; \
  } while (0)

#define WAIT_AN(i) do { \
    for (;;) { \
      if (!(dut->AN & (1 << i))) { \
        break; \
      } \
      TICK(1); \
    } \
  } while (0)

#define C2SEG() ({ \
    int res = 0; \
    res = dut->CA; \
    res = (res << 1) | dut->CB; \
    res = (res << 1) | dut->CC; \
    res = (res << 1) | dut->CD; \
    res = (res << 1) | dut->CE; \
    res = (res << 1) | dut->CF; \
    res = (res << 1) | dut->CG; \
    res; \
  })

#define C2DIGIT() ({ \
    int seg = C2SEG(); \
    int res = -1; \
    for (int i = 0; i < 10; ++i) { \
      if (segments[i] == seg) { \
        res = i; \
        break; \
      } \
    } \
    res; \
  })

#define GET_ALL_DIGITS() ({ \
    int res = 0; \
    for (int i = 0; i < 8; ++i) { \
      WAIT_AN(i); \
      res = res + power(10, i) * C2DIGIT(); \
    } \
    res; \
  })

int power(int base, int exp) {
  if (exp == 0) return 1;
  
  int x = power(base, exp / 2);
  if (exp % 2 == 0) {
    return x * x;
  } else {
    return base * x * x;
  }
}

int main(int argc, char** argv) {
  const auto contextp = std::make_unique<VerilatedContext>();
  contextp->commandArgs(argc, argv);

  auto dut = std::make_unique<Vtop>(contextp.get());

  uint32_t expected_value = 0;
  uint32_t actual_value;
  
  RESET(10);

  // check 8 digits
  actual_value = GET_ALL_DIGITS();
  if (actual_value != 0) {
    ERROR("Test failed for reset\n");
    goto failure;
  }

  for (;;) {
    if (expected_value > 100) break;

    PRESS();
    expected_value++;
    actual_value = GET_ALL_DIGITS();
    
    INFO("[time %20ld] ", contextp->time());
    std::cout << "Expected value: " << expected_value << " | "
              << "Actual value: " << actual_value << '\n';

    if (actual_value != expected_value) {
      ERROR("Test failed for counter value %d\n", expected_value);
      goto failure;
    }
  }

  SUCCESS("==== tb_top passed ====\n");
  return 0;

failure:
  return 1;
}


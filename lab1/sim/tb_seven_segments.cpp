#include <iostream>
#include <bitset>
#include <verilated.h>
#include "VSevenSegments.h"
#include "utils.h"

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  VSevenSegments* dut = new VSevenSegments;

  int test_inputs[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  int expected_outputs[] = {
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

  bool success = true;

  for (int i = 0; i < 10; ++i) {
    dut->in = test_inputs[i];
    dut->eval();

    std::cout << "Input: " << test_inputs[i] << " | "
              << "Expected Output: " << std::bitset<7>(expected_outputs[i]) << " | "
              << "Actual Output: " << std::bitset<7>(dut->out) << '\n';

    if (dut->out != expected_outputs[i]) {
      success = false;
      ERROR("Test failed for input %d\n", test_inputs[i]);
      break;
    }
  }

  if (success) {
    SUCCESS("==== tb_seven_segments passed ====\n");
  }

  delete dut;
  return success ? 0 : 1;
}

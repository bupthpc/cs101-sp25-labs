#pragma once

#include "types.h"

#define FPGA_LEDS (*((volatile u16*)0x80000000))
#define FPGA_SWITCHES (*((volatile u16*)0x80000020))
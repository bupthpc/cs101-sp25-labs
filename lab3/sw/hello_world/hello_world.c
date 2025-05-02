#include "uart.h"
#include "memory_map.h"

// Assume CPI=1
// 100MHz -> 100M inst/s -> 20M inst / 0.2s
// 50MHz -> 50M inst/s -> 10M inst / 0.2s
// 10MHz  -> 10M inst/s  -> 2M inst / 0.2s

#define WAIT_TIME 2000000

#define WAIT(t) for (int i = 0; i < (t); ++i) { \
  asm volatile ("nop"); \
}

#define SAY_HELLO() do {  \
  uart_write_u8('H');     \
  uart_write_u8('e');     \
  uart_write_u8('l');     \
  uart_write_u8('l');     \
  uart_write_u8('o');     \
  uart_write_u8(',');     \
  uart_write_u8(' ');     \
  uart_write_u8('W');     \
  uart_write_u8('o');     \
  uart_write_u8('r');     \
  uart_write_u8('l');     \
  uart_write_u8('d');     \
  uart_write_u8('!');     \
  uart_write_u8('\r');    \
  uart_write_u8('\n');    \
} while (0)

int main() {
  SAY_HELLO();
}

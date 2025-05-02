#include "uart.h"

u8 uart_read_u8() {
  while (!UART_RX_VALID)
    ;
  u8 rx_data = UART_RX_DATA;
  return rx_data;
}

void uart_write_u8(u8 tx_data) {
  while (!UART_TX_READY)
    ;
  UART_TX_DATA = tx_data;
}

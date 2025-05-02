#pragma once

#include "types.h"

#define UART_TX_READY (*((volatile u8*)0x80000010) & 0x08)
#define UART_TX_DATA  (*((volatile u8*)0x80000018))
#define UART_RX_VALID (*((volatile u8*)0x80000010) & 0x01)
#define UART_RX_DATA  (*((volatile u8*)0x80000014))

u8 uart_read_u8();

void uart_write_u8(u8 tx_data);

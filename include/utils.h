#pragma once

#include <cstdio>

#define ANSI_FG_RED     "\33[1;31m"
#define ANSI_FG_GREEN   "\33[1;32m"
#define ANSI_FG_BLUE    "\33[1;34m"
#define ANSI_NONE       "\33[0m"

#define ANSI_FMT(str, fmt) fmt str ANSI_NONE

#define INFO(fmt, ...) fprintf(stdout, ANSI_FMT(fmt, ANSI_FG_BLUE), ##__VA_ARGS__)
#define SUCCESS(fmt, ...) fprintf(stdout, ANSI_FMT(fmt, ANSI_FG_GREEN), ##__VA_ARGS__)
#define ERROR(fmt, ...) fprintf(stderr, ANSI_FMT(fmt, ANSI_FG_RED), ##__VA_ARGS__)

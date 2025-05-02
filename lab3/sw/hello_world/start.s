.section    .start
.global     _start

_start:
    li      sp, 0x10002000
    jal     main

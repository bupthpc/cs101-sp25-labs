#! /usr/bin/env python3

import sys
import os
import subprocess

# Include path to grade_utils
script_dir = os.path.join(os.path.dirname(__file__), '..', 'scripts')
sys.path.append(script_dir)

from grade_utils import *

SRC_DIR = os.path.join(os.path.dirname(__file__), 'src')

@test(0, "lint always", critical=True)
def test_lint_always():
    for file in os.listdir(SRC_DIR):
        path = os.path.join(SRC_DIR, file)
        lint_always(path)

def make_test(target, points, title):
    @test(points, title)
    def _test():
        result = subprocess.run(
            ['make', target],
            stderr=subprocess.STDOUT,
            stdout=subprocess.PIPE,
            text=True
        )
        if result.returncode != 0:
            print(result.stdout)
            raise AssertionError(f"{target} failed")
    return _test


make_test("tb_uart_transmitter", 5, "uart_transmitter")
make_test("tb_uart2uart", 10, "uart2uart")
make_test("tb_fifo", 5, "fifo")
make_test("tb_echo", 10, "echo")
make_test("tb_simple_echo", 10, "simple_echo")

run_all_tests()

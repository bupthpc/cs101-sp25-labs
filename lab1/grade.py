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


make_test("tb_seven_segments", 5, "seven_segments")
make_test("tb_counter", 5, "counter")
make_test("tb_synchronizer", 5, "synchronizer")
make_test("tb_debouncer", 5, "debouncer")
make_test("tb_edge_detector", 5, "edge_detector")
make_test("tb_top", 20, "top module")

run_all_tests()

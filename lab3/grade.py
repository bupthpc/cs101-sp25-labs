#! /usr/bin/env python3

import sys
import os
import glob
import subprocess

# Include path to grade_utils
script_dir = os.path.join(os.path.dirname(__file__), '..', 'scripts')
sys.path.append(script_dir)

from grade_utils import *

SRC_DIR = os.path.join(os.path.dirname(__file__), 'src')

@test(0, "lint always", critical=True)
def test_lint_always():
    for path in glob.glob(os.path.join(SRC_DIR, '**', '*.sv'), recursive=True):
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


make_test("tb_alu", 5, "alu")
make_test("tb_register_file", 5, "register_file")
make_test("tb_immediate_generator", 5, "immediate_generator")
make_test("tb_controller", 5, "controller")
make_test("tb_cpu", 20, "cpu")
# make_test("tb_hello_world", 20, "hello_world")

run_all_tests()

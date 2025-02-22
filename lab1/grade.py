#! /usr/bin/env python3

import sys
import os
import subprocess

script_dir = os.path.join(os.path.dirname(__file__), '..', 'scripts')
sys.path.append(script_dir)

from grade_utils import *

@test(0, "lint always", critical=True)
def test_lint_always():
    # get all the file in src directory
    src_dir = os.path.join(os.path.dirname(__file__), 'src')
    files = os.listdir(src_dir)
    for file in files:
        lint_always(os.path.join(src_dir, file))

@test(5, "seven_segments")
def test_seven_segments():
    result = subprocess.run(
        ['make', 'tb_seven_segments'],
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
        text=True)

    if result.returncode != 0:
        print(result.stdout)
        raise AssertionError("tb_seven_segments failed")

@test(5, "counter")
def test_counter():
    result = subprocess.run(
        ['make', 'tb_counter'],
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
        text=True)

    if result.returncode != 0:
        print(result.stdout)
        raise AssertionError("tb_counter failed")

@test(5, "synchronizer")
def test_synchronizer():
    result = subprocess.run(
        ['make', 'tb_synchronizer'],
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
        text=True)
    
    if result.returncode != 0:
        print(result.stdout)
        raise AssertionError("tb_synchronizer failed")

@test(5, "debouncer")
def test_debouncer():
    result = subprocess.run(
        ['make', 'tb_debouncer'],
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
        text=True)
    
    if result.returncode != 0:
        print(result.stdout)
        raise AssertionError("tb_debouncer failed")
    

@test(5, "edge_detector")
def test_edge_detector():
    result = subprocess.run(
        ['make', 'tb_edge_detector'],
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
        text=True)
    
    if result.returncode != 0:
        print(result.stdout)
        raise AssertionError("tb_edge_detector failed")

@test(20, "top module")
def test_edge_detector():
    result = subprocess.run(
        ['make', 'tb_top'],
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
        text=True)
    
    if result.returncode != 0:
        print(result.stdout)
        raise AssertionError("tb_top failed")

run_all_tests()
import sys
import os
import re
import time

__all__ = []

################################################################################


# ------------------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------------------


TESTS = []
TOTAL = 0
POSSIBLE = 0


# ------------------------------------------------------------------------------
# Decorator to register tests
# ------------------------------------------------------------------------------


__all__ += ['test', 'run_all_tests']

def test(points, title=None, critical=False):
    def register(fn):
        def wrapper():
            nonlocal points, title, critical
            global TOTAL, POSSIBLE

            title_display = title or fn.__name__
            sys.stdout.write(f"== Test {title_display} ==\n")
            sys.stdout.flush()
            fail = None
            start = time.time()

            try:
                fn()
            except AssertionError as e:
                fail = str(e)

            POSSIBLE += points
            if points or critical:
                status = color("red", "FAIL") if fail else color("green", "OK")
                print(f"{title_display}: {status}", end=' ')
            elapsed = time.time() - start
            if elapsed > 0.1:
                print(f"({elapsed:.1f}s)", end=' ')
            print()

            if fail:
                print("    " + fail.replace("\n", "\n    "))
            else:
                TOTAL += points

            wrapper.ok = fail is None
            return wrapper.ok

        # Record test metadata on the test wrapper function
        wrapper.__name__ = fn.__name__
        wrapper.title = title or fn.__name__
        wrapper.ok = False
        wrapper.critical = critical

        TESTS.append(wrapper)
        return wrapper
    return register


# ------------------------------------------------------------------------------
# Test runner
# ------------------------------------------------------------------------------


def run_all_tests():
    try:
        for t in TESTS:
            t()
            if t.critical and not t.ok:
                print(f"Critical test {t.title} failed")
                print(f"Score: 0/{POSSIBLE}")
                break
        else: # no break
            print("Score: %d/%d" % (TOTAL, POSSIBLE))
    except KeyboardInterrupt:
        pass
    if TOTAL < POSSIBLE:
        sys.exit(1)


# ------------------------------------------------------------------------------
# Lint checker
# ------------------------------------------------------------------------------


__all__ += ['lint_always']

def lint_always(file_path):
    with open(file_path) as f:
        text = f.read()
        
    search = re.search(r"always\s+@\s*\((posedge|negedge)\s+", text)
    if search:
        raise AssertionError(
            f"{file_path}: You are not allowed to use `always @(posedge/negedge ...)` in this lab")
    

# ------------------------------------------------------------------------------
# Color printer
# ------------------------------------------------------------------------------


_COLORS = {
    "default": "\033[0m",
    "red": "\033[31m",
    "green": "\033[32m",
}

def color(name, text):
    return f"{_COLORS[name]}{text}{_COLORS['default']}"
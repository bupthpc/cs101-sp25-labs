import sys, os, re, time

__all__ = []

################################################################################

TESTS = []
TOTAL = POSSIBLE = 0

__all__ += ['test', 'run_all_tests']

def test(points, title=None, critical=False):
    def register_test(fn, title=title, critical=critical):
        def run_test():
            global TOTAL, POSSIBLE

            fail = None
            start = time.time()

            sys.stdout.write("== Test %s ==\n" % title)
            sys.stdout.flush()
            try:
                fn()
            except AssertionError as e:
                fail = str(e)

            POSSIBLE += points
            if points or critical:
                print("%s: %s" % (title, \
                    (color("red", "FAIL") if fail else color("green", "OK"))), end=' ')
            if time.time() - start > 0.1:
                print("(%.1fs)" % (time.time() - start), end=' ')
            print()
            if fail:
                print("    %s" % fail.replace("\n", "\n    "))
            else:
                TOTAL += points

            run_test.ok = not fail
            return run_test.ok

        # Record test metadata on the test wrapper function
        run_test.__name__ = fn.__name__
        run_test.title = title
        run_test.ok = False
        run_test.critical = critical
        TESTS.append(run_test)
        return run_test
    return register_test

        

def run_all_tests():
    try:
        for test in TESTS:
            test()
            if test.critical and not test.ok:
                print(f"Critical test {test.title} failed")
                print("Score: 0/%d" % POSSIBLE)
                break
        print("Score: %d/%d" % (TOTAL, POSSIBLE))
    except KeyboardInterrupt:
        pass
    if TOTAL < POSSIBLE:
        sys.exit(1)

################################################################################

__all__ += ['lint_always']

def lint_always(file_path):
    with open(file_path) as f:
        text = f.read()
        
    # search `always @(posedge/negedge ...)`
    search = re.search(r"always\s+@\s*\((posedge|negedge)\s+", text)
    if search:
        raise AssertionError(
            f"{file_path}: You are not allowed to use `always @(posedge/negedge ...)` in this lab")
    

################################################################################

COLORS = {"default": "\033[0m", "red": "\033[31m", "green": "\033[32m"}

def color(name, text):
    return COLORS[name] + text + COLORS["default"]
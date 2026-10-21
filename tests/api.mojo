# Edge cases the oracle grid does not name. Every expected string is Python's format() output.
from std.testing import assert_equal, assert_raises
from pyformat import fmt, fmt_int, fmt_fixed, fmt_e, fmt_g, fmt_pct, fmt_commas, py_sum


def main() raises:
    # ties go to even on the exact binary value
    assert_equal(fmt_fixed(2.5, 0), "2")
    assert_equal(fmt_fixed(0.5, 0), "0")
    assert_equal(fmt_fixed(1.5, 0), "2")
    assert_equal(fmt_fixed(0.6, 0), "1")
    assert_equal(fmt_fixed(9.5, 0), "10")
    assert_equal(fmt_fixed(2.675, 2), "2.67")  # the double is below 2.675
    assert_equal(fmt_fixed(1.005, 2), "1.00")
    assert_equal(fmt_fixed(0.05, 1), "0.1")  # the double is above 0.05
    assert_equal(fmt_fixed(0.0005, 3), "0.001")
    # sign survives rounding to zero; -0.0 prints its sign
    assert_equal(fmt_fixed(-0.0049, 2), "-0.00")
    assert_equal(fmt_fixed(-0.0, 1), "-0.0")
    assert_equal(fmt_g(-0.0, 6), "-0")
    # long precision and magnitude: exact digits, no overflow
    assert_equal(fmt_fixed(0.1, 20), "0.10000000000000000555")
    assert_equal(fmt_fixed(1e22, 1), "10000000000000000000000.0")
    assert_equal(fmt_fixed(1234567.891, 1), "1234567.9")
    assert_equal(fmt_e(5e-324, 3), "4.941e-324")
    # g: switch to exponent at 10^P and below 1e-4, trailing zeros dropped, rounding can carry
    assert_equal(fmt_g(123456.0, 6), "123456")
    assert_equal(fmt_g(1234567.0, 6), "1.23457e+06")
    assert_equal(fmt_g(0.0001, 6), "0.0001")
    assert_equal(fmt_g(0.00001, 6), "1e-05")
    assert_equal(fmt_g(100000.0, 3), "1e+05")
    assert_equal(fmt_g(999999.5, 6), "1e+06")
    assert_equal(fmt_g(0.0, 6), "0")
    assert_equal(fmt_g(1e100, 6), "1e+100")
    assert_equal(fmt_g(1e15, 17), "1000000000000000")
    assert_equal(fmt_g(1e16, 6, 11), "      1e+16")
    # e
    assert_equal(fmt_e(0.0, 6), "0.000000e+00")
    assert_equal(fmt_e(12345.678, 6), "1.234568e+04")
    assert_equal(fmt_e(12345.678, 0), "1e+04")
    assert_equal(fmt_e(9.9999995, 6), "9.999999e+00")
    # %: x * 100 in double arithmetic first, as CPython does
    assert_equal(fmt_pct(0.256, 1), "25.6%")
    assert_equal(fmt_pct(1.005, 0), "100%")
    assert_equal(fmt_pct(Float64.MAX * 2, 1), "inf%")
    # non-finite
    assert_equal(fmt_fixed(Float64.MAX * 2, 1), "inf")
    assert_equal(fmt_e(-Float64.MAX * 2, 1, 8), "    -inf")
    assert_equal(fmt_pct(Float64.MAX * 2 - Float64.MAX * 2, 1), "nan%")
    # fmt: the spec string
    assert_equal(fmt(3.14159, "10.2f"), "      3.14")
    assert_equal(fmt(3.14159, "<10.2f"), "3.14      ")
    assert_equal(fmt(3.14159, "^10.2f"), "   3.14   ")
    assert_equal(fmt(3.14159, "*^11.2f"), "***3.14****")
    assert_equal(fmt(3.14159, "x>10.3g"), "xxxxxx3.14")
    assert_equal(fmt(0.5, "f"), "0.500000")  # no precision means 6
    assert_equal(fmt(0.25, "%"), "25.000000%")
    assert_equal(fmt(1234567.0, "g"), "1.23457e+06")
    assert_equal(fmt(3.14159, "2.2f"), "3.14")  # width smaller than the text: no cut
    # fmt_int: whole numbers of any size, exact
    assert_equal(fmt_int(0.0, ","), "0")
    assert_equal(fmt_int(999.0, ","), "999")
    assert_equal(fmt_int(1000.0, ","), "1,000")
    assert_equal(fmt_int(-1234567.0, ">12,"), "  -1,234,567")
    assert_equal(fmt_int(1e20, ","), "100,000,000,000,000,000,000")
    assert_equal(fmt_int(18446744073709551616.0, "<30,"), "18,446,744,073,709,551,616    ")
    assert_equal(fmt_int(1e30, ","), "1,000,000,000,000,000,019,884,624,838,656")
    assert_equal(fmt_int(123.0, "d"), "123")
    assert_equal(fmt_int(-5.0, "*^9"), "***-5****")
    assert_equal(fmt_int(Float64.MAX * 2, ">6,"), "   inf")
    # fmt_commas (Int)
    assert_equal(fmt_commas(0), "0")
    assert_equal(fmt_commas(1234567), "1,234,567")
    assert_equal(fmt_commas(-1234567, 12), "  -1,234,567")
    assert_equal(fmt_commas(-9223372036854775807 - 1), "-9,223,372,036,854,775,808")
    # unsupported or malformed specs raise instead of returning something else
    with assert_raises(contains="zero padding"):
        _ = fmt(1.0, "08.2f")
    with assert_raises(contains="missing precision"):
        _ = fmt(1.0, ".f")
    with assert_raises(contains="unsupported float"):
        _ = fmt(1.0, "10")
    with assert_raises(contains="unsupported float"):
        _ = fmt(1234.5, ",.1f")
    with assert_raises(contains="invalid"):
        _ = fmt(1.0, ".2ff")
    with assert_raises(contains="whole number"):
        _ = fmt_int(1.5, ",")
    with assert_raises(contains="unsupported int"):
        _ = fmt_int(1.0, ".2f")
    # py_sum: CPython 3.12+ compensated sum
    var xs = List[Float64]()
    for _ in range(10):
        xs.append(0.1)
    assert_equal(py_sum(xs), 1.0)
    print("api ok")

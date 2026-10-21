from pyformat import fmt, fmt_fixed, fmt_g, fmt_int


def main() raises:
    print(fmt_fixed(2.675, 2))  # 2.67: rounds the exact binary value, as Python does
    print(fmt_g(1234567.0, 6))  # 1.23457e+06
    print(fmt(0.256, ".1%"))  # 25.6%
    print(fmt(3.14159, "*^11.2f"))  # ***3.14****
    print(fmt_int(1e20, ">28,"))  # whole numbers beyond Int: 100,000,000,000,000,000,000

"""Oracle: Python format() over a fixed grid of values x specs. Prints
"<spec> <float64 bits> <result>" per line; the Mojo runner prints the same."""
import math, random, struct
SPECS = [".0f", ".1f", ".2f", ".3f", ".6f", "8.2f", ",", ">12,", "g", ".3g", ".6g", ".10g", ".1%", ".0%", ".2%", "e", ".3e", ".99999999999999999999f", "99999999999999999999.2f", ">9223372036854775808,"]
def bits(x): return struct.unpack("<q", struct.pack("<d", x))[0]
vals = [0.0, -0.0, 0.5, 1.5, 2.5, -2.5, 2.675, 1.005, 0.125, 0.375, 1e-7, 1e-5, 0.0001, 123456789.0, 1e15, 1e16, 1e17,
        1e21, 1e22, 1.7976931348623157e308, 5e-324, 2.2250738585072014e-308, 0.1, 0.2, 0.3, 1/3, 2/3, 99.995, 99.9949999,
        float("inf"), float("-inf"), float("nan"), 12345.678, -0.0049, 0.0049999, 1234567.891, 0.999999, 9.9999995]
r = random.Random(1)
vals += [r.uniform(-1e6, 1e6) for _ in range(300)] + [10 ** r.uniform(-12, 20) for _ in range(300)]
for spec in SPECS:
    for v in vals:
        x = v if spec not in (",", ">12,") else float(int(v)) if math.isfinite(v) else v
        try: out = format(int(x) if spec in (",", ">12,") and math.isfinite(x) else x, spec)
        except (ValueError, OverflowError) as e: out = "ERR"
        print(spec, bits(x), out)
for v in vals + [3.0000000050617508e+16, 9.999999999999996e+15, 1e16, 9999999999999998.0, 0.0001, 0.00009999, 1e-4, 5e-5, 123.0, 1e100, -1e-300, 2**53 + 0.0, 2.0**63, 4.35, 0.1 + 0.2]:
    print("repr", bits(v), repr(v))
for k in range(-1074, 1024):                             # every power of two (shortest-digit ties)
    print("repr", bits(2.0 ** k), repr(2.0 ** k))

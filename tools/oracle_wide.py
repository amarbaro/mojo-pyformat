"""Second oracle: random 64-bit patterns (subnormals, huge exponents) x wide specs (precision to 100,
fill, align, width), plus whole numbers up to 1.8e308 through the int path.
Prints "<spec> <float64 bits> <result>" per line, like tools/oracle.py."""
import math, random, struct
def bits(x): return struct.unpack("<q", struct.pack("<d", x))[0]
def flt(b): return struct.unpack("<d", struct.pack("<Q", b))[0]
r = random.Random(7)
xs = [flt(r.getrandbits(64)) for _ in range(400)]
xs += [flt(r.getrandbits(52)) for _ in range(100)]            # subnormals
xs += [r.uniform(-1e3, 1e3) for _ in range(200)] + [k + 0.5 for k in range(-6, 7)] + [x / 8 for x in range(-40, 40)]
xs += [5e-324, 1.7976931348623157e308, 9.5, 99.5, 0.95, 0.0095, 9.999999999999999e22, 1e23, 0.3, 1e-5, 9.9999995e-5]
specs = [f".{p}{t}" for t in "feg%" for p in (0, 1, 2, 5, 9, 17, 25, 40, 100)]
specs += ["*^20.3f", "<15e", ">10g", "^9.1%", "x<8.0f", "20.4f", "^21.5e", "-<12.2g", "0>8.3f", "1.0f", "10.1e"]
for spec in specs:
    for x in xs:
        print(spec, bits(x), format(x, spec))
ints = [10 ** k for k in range(0, 309, 7)] + [2 ** k for k in range(0, 1024, 61)] + [r.getrandbits(r.randint(1, 1023)) for _ in range(300)]
ints = [i for i in ints if i < 2 ** 1024 and math.isfinite(float(i))]
for spec in [",", ">12,", "<30,", "*^40,", "d", "15", "-<9"]:
    for i in ints:
        x = float(i)
        for sx in (x, -x):
            print(spec, bits(sx), format(int(sx), spec))

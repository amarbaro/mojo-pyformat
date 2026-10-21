# Gate runner. Reads "<spec> <float64 bits>" from the first two fields of each line of argv[1]
# (default .work/exp.txt, the oracle's own output; field 3, the expected result, is never read)
# and prints "<spec> <bits> <result>". A spec that ends in f, e, g or % is a float spec, any other an int spec.
from std.memory import bitcast
from std.sys import argv
from pyformat import fmt, fmt_int


def main() raises:
    var out = String()
    for line in open(argv()[1] if len(argv()) > 1 else ".work/exp.txt", "r").read().splitlines():
        var f = line.split(" ")
        var spec = String(f[0])
        var x = bitcast[DType.float64](Int64(Int(f[1])))
        var r: String
        try:
            r = fmt(x, spec) if spec[byte=spec.byte_length() - 1] in "feg%" else fmt_int(x, spec)
        except:
            r = "ERR"
        out += spec + " " + String(f[1]) + " " + r + "\n"
    print(out, end="")

---
name: mojo-pyformat
description: "Format numbers in Mojo exactly as Python's format() does: fixed, exponent, general, percent and thousands separators. Use when Mojo code prints floats and must match Python output byte for byte."
---

# mojo-pyformat

Python `format()` for `Float64` in Mojo 1.2, checked against CPython on 53,700 cases. Rounding is
half to even on the exact binary value (`2.675` -> `2.67`).

## Install

`mojo run -I <repo>/src app.mojo`, or `mojo precompile <repo>/src/pyformat -o pyformat.mojoc`,
or copy `src/pyformat/`.

## Use

```mojo
from pyformat import fmt, fmt_int, fmt_fixed, fmt_g, fmt_e, fmt_pct, fmt_commas, py_sum

def main() raises:
    print(fmt_fixed(3.14159, 2, 8))     # "    3.14"   == f"{x:8.2f}"
    print(fmt_g(1234567.0, 6))          # "1.23457e+06" == f"{x:.6g}"
    print(fmt(0.256, ".1%"))            # "25.6%"
    print(fmt_commas(1234567, 12))      # "   1,234,567"
    print(fmt_int(1e20, ","))           # whole number beyond Int
```

- A fixed spec in code: use `fmt_fixed/e/g/pct(x, prec, width)`. They do not raise.
- A spec that arrives as a string: `fmt(x, spec)`, which raises on a bad or unsupported spec.
- A whole number bigger than `Int`, or one with `,` grouping from a double: `fmt_int(x, spec)`.
- `sum(xs)` of floats the way CPython sums: `py_sum`.

## Avoid

- `0` padding, `+`/space sign, `#`, `_`, upper-case types, a spec with no type, `,` on a float:
  all raise. Pad with `fmt_fixed(x, p, width)` or a fill (`"0>8.2f"`; a `-` stays after the zeros).
- Do not use the spec fill with a non-ASCII character; width counts bytes.
- Do not parse the result back to check it: compare with Python's `format()` (see `tools/oracle.py`).
- Do not "fix" a surprising digit (`0.05` -> `"0.1"`, `2.675` -> `"2.67"`): that is the exact binary
  value, and it is what Python prints.

# mojo-pyformat

[![CI](https://github.com/amarbaro/mojo-pyformat/actions/workflows/ci.yml/badge.svg)](https://github.com/amarbaro/mojo-pyformat/actions/workflows/ci.yml)

Python's `format()` for numbers in Mojo, character for character: `{:.2f}`, `{:g}`, `{:e}`,
`{:%}` and `{:,}`, with the rounding decided on the double's exact binary value, as CPython
does. `.2f` runs 5.9× faster than Python; `g` and `e` run 1.8× to 2×.

```mojo
from pyformat import fmt, fmt_fixed, fmt_int

def main() raises:
    print(fmt_fixed(2.675, 2))        # 2.67  (the double is below 2.675)
    print(fmt(0.256, ".1%"))          # 25.6%
    print(fmt(1234567.0, "g"))        # 1.23457e+06
    print(fmt_int(1e20, ">28,"))      # 100,000,000,000,000,000,000
```

## Install

Requires Mojo 1.1.

| Way | Command |
|---|---|
| Source path | `mojo run -I path/to/mojo-pyformat/src app.mojo` |
| Precompiled | `mojo precompile src/pyformat -o pyformat.mojoc`, then put it next to your code |
| Vendor | copy `src/pyformat/` into your project |

## What you get

- `fmt(x, spec)`: a Python format spec for the types `f`, `e`, `g`, `%`, with fill, align,
  width and precision. No precision means 6, as in Python.
- `fmt_int(x, spec)`: `format(int(x), spec)` for a whole number held in a `Float64`, with
  `,` grouping. Any Python int up to 1.8e308 is a double exactly, so this goes beyond `Int`.
- `fmt_fixed`, `fmt_e`, `fmt_g`, `fmt_pct` `(x, prec, width=0)`, `fmt_commas(n: Int, width=0)`
  and `py_sum`: the fixed-signature forms. `fmt_fixed`, `fmt_g`, `fmt_commas` and `py_sum`
  keep the signatures of the module this library grew from.

Every behaviour is in [docs/api.md](docs/api.md); the memory and speed design is in
[docs/design.md](docs/design.md).

## Performance

`tests/bench.mojo` against `tools/bench_oracle.py`: 1,000,000 values `(i * 2654435761 % 10^7) / 1000`,
each formatted as `.2f`, `g` and `.3e`, with the same checksum of output lengths. Three runs each.

| | `.2f` | `g` | `.3e` | peak RSS |
|---|---|---|---|---|
| Python 3.14 `format()` | 234 to 242 ms | 223 to 231 ms | 245 to 255 ms | 10.0 to 10.2 MB |
| mojo-pyformat | 40 ms | 126 ms | 125 to 129 ms | 11.9 to 12.2 MB |

The RSS difference is the Mojo runtime (an empty Mojo program uses 11.6 MB); the formatter
allocates one output buffer per call and nothing else on the heap.

## Limits

- `Float64` only. Types `f`, `e`, `g`, `%` for floats; `,` and `d` only through `fmt_int`.
- Not supported, and they raise rather than guess: `+`/space sign, `0` padding, `#`, `_`,
  upper-case types, a spec without a type, `,` on a float, a multi-byte fill character.
- Width counts bytes, not characters (the fill is one ASCII byte).
- `fmt_int` raises for a number that is not whole.

## Check

```
scripts/ci.sh
```

It runs `uv sync`, builds the runner, then: `scripts/check.sh` compares the runner with
`tools/oracle.py` (Python `format()`, 10,846 value and spec pairs, exact float bits in, text out);
`tools/oracle_wide.py` does the same for 42,856 pairs with random 64-bit patterns (subnormals,
huge exponents), precisions up to 100, fill, align, width, and whole numbers up to 1.8e308;
`tests/api.mojo` covers ties, signs, non-finite values, spec errors and `py_sum`.
CI runs the same script on every push.

## For coding agents

[skills/mojo-pyformat/SKILL.md](skills/mojo-pyformat/SKILL.md).

## Licence

Apache-2.0, see [LICENSE](LICENSE).

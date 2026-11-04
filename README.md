# mojo-pyformat

<!-- badges -->
[![ci](https://github.com/amarbaro/mojo-pyformat/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/amarbaro/mojo-pyformat/actions/workflows/ci.yml) [![latest release](https://img.shields.io/github/v/release/amarbaro/mojo-pyformat)](https://github.com/amarbaro/mojo-pyformat/releases/latest) [![license](https://img.shields.io/github/license/amarbaro/mojo-pyformat)](https://github.com/amarbaro/mojo-pyformat/blob/main/LICENSE)
<!-- /badges -->

<!-- install -->
Install: `pixi add mojo-pyformat` once published. For now: `git clone https://github.com/amarbaro/mojo-pyformat`, then `mojo run -I mojo-pyformat/src app.mojo`.

```mojo
from pyformat import fmt, fmt_fixed, fmt_g, fmt_int


def main() raises:
    print(fmt_fixed(2.675, 2))  # 2.67: rounds the exact binary value, as Python does
    print(fmt_g(1234567.0, 6))  # 1.23457e+06
    print(fmt(0.256, ".1%"))  # 25.6%
    print(fmt(3.14159, "*^11.2f"))  # ***3.14****
    print(fmt_int(1e20, ">28,"))  # whole numbers beyond Int: 100,000,000,000,000,000,000
```
<!-- /install -->

Python's `format()` for numbers in Mojo, character for character: `{:.2f}`, `{:g}`, `{:e}`,
`{:%}` and `{:,}`, with the rounding decided on the double's exact binary value, as CPython
does. `.2f` runs 5.9× faster than Python; `g` and `e` run 1.8× to 2×.

Requires Mojo 1.2.

## What you get

- `py_repr(x)`: Python `repr(float)` exactly. Mojo 1.2's own float printing is not round-trip safe (two different doubles print the same), so text that must equal Python goes through this.

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
`tools/oracle.py` (Python `format()` and `repr()`, 15,511 value and spec pairs, 2,751 of them `repr` (all 2,098 powers of two included), exact float bits in, text out);
`tools/oracle_wide.py` does the same for 43,660 pairs with random 64-bit patterns (subnormals,
huge exponents), precisions up to 100, fill, align, width, and whole numbers up to 1.8e308;
`tests/api.mojo` covers ties, signs, non-finite values, spec errors and `py_sum`.
CI runs the same script on every push.

## For coding agents

[skills/mojo-pyformat/SKILL.md](skills/mojo-pyformat/SKILL.md).

## Licence

Apache-2.0, see [LICENSE](LICENSE).

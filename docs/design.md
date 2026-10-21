# Design

Three rules decide the layout: round once, on the exact value; keep every working buffer on the
stack; give the common case a path that does no digit expansion at all.

## One exact digit string, every type is a rounding of it

CPython rounds on the double's exact binary value, so `2.675` formats as `2.67` and `0.05` as `0.1`.
The shortest repr digits are not enough (they would say `2.675` is a tie). So `_Dec` expands
`|x| = m * 2^e` exactly: for `e >= 0`, multiply `m` by 2^e; for `e < 0`, strip the common factors
of 2 and multiply by 5^k, so `|x| = m * 5^k / 10^k` and the decimal digits are those of `m * 5^k`.
The multiplications run on base-1e9 `UInt32` limbs, 2^32 or 5^13 at a time.

`f`, `e` and `g` are then the same function, `round_to(c)` (keep c digits, half to even; the tail
is nonzero whenever a digit follows, because trailing zeros are stripped), plus a layout loop.
No type has its own rounding code, so a rounding bug cannot hide in one type.

## The buffers are on the stack

The worst case is `5e-324`: `5^1074` has 751 digits, `m * 5^1074` for a subnormal at most 767, which
is 86 limbs. The limb array is 96 `UInt32` (384 B) and the digit array 800 bytes, both `Array`s
created uninitialised. The only heap allocation in a call is the output, sized from the digit count
(`List(capacity=)`), and one copy into the `String`. RSS stays at the Mojo runtime's 11.6 MB.

## `f` skips the expansion when it fits in 64 bits

`.2f` is by far the most used call. When `2^-11 <= |x| < 2^53` and `m * 10^prec < 2^64`, the result
is `m * 10^prec >> k` with the remainder compared to half, in plain `UInt64`: no limbs, no digit
array. That covers precision up to 3 for every double in range, more for short mantissas. Anything
else (zero, tiny, huge, long precision) takes the exact path, so the fast path is only ever an
optimisation, and `tools/oracle_wide.py` (precisions 0 to 100, random bit patterns) covers both sides
of its guards.

| 1,000,000 values | `.2f` | `g` | `.3e` |
|---|---|---|---|
| exact expansion for everything | 124 ms | 126 ms | 125 ms |
| with the 64-bit path for `f` | 40 ms | 126 ms | 125 to 129 ms |
| Python `format()` | 234 to 242 ms | 223 to 231 ms | 245 to 255 ms |

`g` and `e` stay on the expansion: about 90 ns of the 125 ns is the limb arithmetic and the digit
split, because a value like `i / 1000` has 43 significant digits to expand. Stopping early would need
a bound on the discarded tail, which costs more code than it saves here.

## `%` multiplies in double, `fmt_int` reuses the expansion

CPython computes `x * 100` in double arithmetic and then formats with `f`; so does `_body`, on the
product. (An exact decimal shift would differ for some inputs.) `fmt_int` needs the digits of a
whole double up to 1.8e308, which are the same `_Dec` digits with no fraction; commas are inserted
while the digits are copied out.

## Correctness: Python is the oracle

`tools/oracle.py` and `tools/oracle_wide.py` print `spec, float64 bits, Python's result` per line.
`tests/cases.mojo` reads only the first two fields and prints the third from this library;
`scripts/check.sh` and `scripts/ci.sh` diff the two. Bits are exchanged as integers so no float
parse or print sits between the two sides.

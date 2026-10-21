# API

All functions are in `pyformat`; every result equals Python's `format()` for the same value
and spec. Each example below is asserted in `tests/api.mojo`.

## `fmt(x: Float64, spec: String) raises -> String`

Spec: `[[fill]align][width][.precision]type`. `fill` is one ASCII byte, `align` is `<`, `>`
(the default) or `^` (the extra space goes right). Types:

| type | meaning | example | result |
|---|---|---|---|
| `f` | fixed | `fmt(3.14159, "10.2f")` | `"      3.14"` |
| `e` | exponent, at least two exponent digits | `fmt(12345.678, ".0e")` | `"1e+04"` |
| `g` | shorter of the two, trailing zeros dropped | `fmt(1234567.0, "g")` | `"1.23457e+06"` |
| `%` | x * 100 in double arithmetic, then `f`, then `%` | `fmt(0.256, ".1%")` | `"25.6%"` |

- No precision means 6: `fmt(0.5, "f")` is `"0.500000"`; `g` with precision 0 means 1.
- `g` uses the exponent form when the rounded exponent is below -4 or at least the precision:
  `fmt_g(100000.0, 3)` is `"1e+05"`, `fmt_g(0.0001, 6)` is `"0.0001"`, `fmt_g(0.00001, 6)` is `"1e-05"`.
- Rounding is half to even on the exact binary value: `fmt_fixed(2.5, 0)` is `"2"`,
  `fmt_fixed(2.675, 2)` is `"2.67"`, `fmt_fixed(0.05, 1)` is `"0.1"`, `fmt_fixed(0.1, 20)` is
  `"0.10000000000000000555"`. A carry changes the width: `fmt_g(999999.5, 6)` is `"1e+06"`.
- The sign bit is always printed: `fmt_fixed(-0.0, 1)` is `"-0.0"`, `fmt_fixed(-0.0049, 2)` is
  `"-0.00"`, `fmt_g(-0.0, 6)` is `"-0"`.
- `inf`, `-inf`, `nan` print as in Python (`nan` has no sign); `%` appends its sign: `"inf%"`, `"nan%"`.
- Numbers of any size are exact: `fmt_fixed(1e22, 1)` is `"10000000000000000000000.0"`,
  `fmt_e(5e-324, 3)` is `"4.941e-324"`.
- A width smaller than the text does not cut it.
- Raises `Error` for anything outside the grammar above, never returns a different format:
  `"08.2f"` (zero padding, `contains="zero padding"`), `".f"` (`"missing precision"`),
  `"10"` and `",.1f"` (`"unsupported float"`), `".2ff"` (`"invalid"`).

## `fmt_int(x: Float64, spec: String) raises -> String`

`format(int(x), spec)` for a whole number `x`. Spec: `[[fill]align][width][,][d]`.

- `fmt_int(1000.0, ",")` is `"1,000"`; `fmt_int(-1234567.0, ">12,")` is `"  -1,234,567"`;
  `fmt_int(-5.0, "*^9")` is `"***-5****"`; `fmt_int(123.0, "d")` is `"123"`.
- Exact beyond `Int`: `fmt_int(1e20, ",")` is `"100,000,000,000,000,000,000"`,
  `fmt_int(1e30, ",")` is `"1,000,000,000,000,000,019,884,624,838,656"` (that is the double 1e30).
- A non-finite `x` prints like a float: `fmt_int(inf, ">6,")` is `"   inf"`.
- Raises for a number that is not whole (`"whole number"`) and for a precision or a float type
  (`"unsupported int"`).

## Fixed-signature forms

`def fmt_fixed(x: Float64, prec: Int, width: Int = 0) -> String`: `format(x, f"{width}.{prec}f")`.
`fmt_e`, `fmt_g`, `fmt_pct` are the same for `e`, `g`, `%`. They cannot raise and are faster than
`fmt` by the spec parse only. `fmt_g` is exact on the binary value (the earlier single-file version
rounded the shortest repr digits and could differ on a tie).

`def fmt_commas(n: Int, width: Int = 0) -> String`: `format(n, f">{width},")` for an `Int`,
including `Int.MIN`: `fmt_commas(-9223372036854775808)` is `"-9,223,372,036,854,775,808"`.

`def py_sum(xs: List[Float64]) -> Float64`: `sum(xs)` as CPython 3.12 and later computes it
(Neumaier compensated summation): `py_sum` of ten `0.1` is `1.0`.

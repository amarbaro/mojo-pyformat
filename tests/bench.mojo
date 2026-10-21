# 1,000,000 values formatted as .2f, g and .3e. Same work as tools/bench_oracle.py.
from std.time import perf_counter_ns
from pyformat import fmt_fixed, fmt_g, fmt_e


def main():
    comptime N = 1_000_000
    var t0 = perf_counter_ns()
    var f = 0
    for i in range(N):
        f += fmt_fixed(Float64((i * 2654435761) % 10_000_000) / 1000.0, 2).byte_length()
    var t1 = perf_counter_ns()
    var g = 0
    for i in range(N):
        g += fmt_g(Float64((i * 2654435761) % 10_000_000) / 1000.0, 6).byte_length()
    var t2 = perf_counter_ns()
    var e = 0
    for i in range(N):
        e += fmt_e(Float64((i * 2654435761) % 10_000_000) / 1000.0, 3).byte_length()
    var t3 = perf_counter_ns()
    print("f_ms", (t1 - t0) // 1_000_000, "g_ms", (t2 - t1) // 1_000_000, "e_ms", (t3 - t2) // 1_000_000, "check", f, g, e)

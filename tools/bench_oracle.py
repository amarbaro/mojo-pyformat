"""Same work as tests/bench.mojo with Python format()."""
import time
def val(i): return ((i * 2654435761) % 10_000_000) / 1000.0
t0 = time.perf_counter()
f = sum(len(f"{val(i):.2f}") for i in range(1_000_000))
t1 = time.perf_counter()
g = sum(len(f"{val(i):g}") for i in range(1_000_000))
t2 = time.perf_counter()
e = sum(len(f"{val(i):.3e}") for i in range(1_000_000))
t3 = time.perf_counter()
print("f_ms", int((t1 - t0) * 1000), "g_ms", int((t2 - t1) * 1000), "e_ms", int((t3 - t2) * 1000), "check", f, g, e)

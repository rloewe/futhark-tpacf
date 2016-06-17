# futhark-tpacf
The parboil benchmark tpacf written in futhark

The files does the following:
- tpacf.fut main benchmark
- tpacf-unoptimized.fut bechmark before memory optimization
- tpacf-f32.fut 32 bit floating point version
- tpacf-i32.fut version with 32 bit integers in the result arrays
- tpacf-1D.fut incomplete version that should imitate the way that tpacf is
parallelized in the Parboil benchmark suite

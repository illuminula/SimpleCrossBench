#include "../shared/z_style.hpp"

__attribute__((optnone)) auto benchCPUZ_callback(i64 n) -> i64
{
    if (n <= 1)
        return 1;
    return benchCPUZ_callback(n - 1) + benchCPUZ_callback(n - 2);
}

extern "C" auto c_benchCPUZ() -> f64
{
    i64 v = 0;
    for (u64 load = 0; load < 100; load++)
        for (u64 i = 1; i < 15; i++)
            v += benchCPUZ_callback(i);
    volatile auto anti_o2 = v;

    return 1.0;
}

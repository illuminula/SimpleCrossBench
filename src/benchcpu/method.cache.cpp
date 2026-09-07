#include "../shared/z_style.hpp"

constexpr auto LOAD_AMOUNT = (u64)5e+3;

__attribute__((no_builtin)) auto benchCache(u8* buf, usize buf_size) -> f64
{
    for (u64 load = 0; load < LOAD_AMOUNT; load++) {
#pragma clang loop unroll(disable)
        for (usize i = 0; i < buf_size / sizeof(at_Vector(64, u8)); i++)
            ((at_Vector(64, u8)*)buf)[i] = {};
    }

    return LOAD_AMOUNT * buf_size / 1e+9;
}

extern "C" auto c_benchCache16K() -> f64
{
    alignas(64) volatile u8 buf[4 << 10]{};
    return benchCache((u8*)buf, sizeof(buf));
}

extern "C" auto c_benchCache192K() -> f64
{
    alignas(64) volatile u8 buf[192 << 10]{};
    return benchCache((u8*)buf, sizeof(buf));
}

extern "C" auto c_benchCache384K() -> f64
{
    alignas(64) volatile u8 buf[384 << 10]{};
    return benchCache((u8*)buf, sizeof(buf));
}

extern "C" auto c_benchCache3M() -> f64
{
    alignas(64) volatile u8 buf[3 << 20]{};
    return benchCache((u8*)buf, sizeof(buf));
}

extern "C" auto c_benchCache6M() -> f64
{
    alignas(64) volatile u8 buf[6 << 20]{};
    return benchCache((u8*)buf, sizeof(buf));
}

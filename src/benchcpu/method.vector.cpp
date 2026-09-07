#include "../shared/z_style.hpp"

constexpr auto LOAD_AMOUNT = (u64)5e+6;

template <typename T, usize Tcount>
auto vectorT() -> f64
{
    T a1{};
    T a2{};
    for (usize i = 0; i < sizeof(T); i++) {
        ((u8*)&a1)[i] = 0x55;
        ((u8*)&a2)[i] = 0x55;
    }
    asm volatile("" ::"r"(&a1), "r"(&a2) :);

    for (u64 load = 0; load < LOAD_AMOUNT; load++) {
        a1 += a2;
        asm volatile("" ::: "memory");
        a1 -= a2;
        asm volatile("" ::: "memory");
        a1 *= a2;
        asm volatile("" ::: "memory");
        a1 /= a2;
        asm volatile("" ::: "memory");
    }

    return Tcount * LOAD_AMOUNT * 4 / 1e+6;
}

extern "C" auto c_vectorINT64() -> f64
{
    return vectorT<at_Vector(8 * 8, i64), 8>();
}

extern "C" auto c_vectorINT32() -> f64
{
    return vectorT<at_Vector(4 * 16, i32), 16>();
}

extern "C" auto c_vectorINT16() -> f64
{
    return vectorT<at_Vector(2 * 32, i16), 32>();
}

extern "C" auto c_vectorFP64() -> f64
{
    return vectorT<at_Vector(8 * 8, f64), 8>();
}

extern "C" auto c_vectorFP32() -> f64
{
    return vectorT<at_Vector(4 * 16, f32), 16>();
}

extern "C" auto c_vectorFP16() -> f64
{
    return vectorT<at_Vector(2 * 32, f16), 32>();
}

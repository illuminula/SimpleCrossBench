#include "../shared/z_style.hpp"
#include <type_traits>

constexpr auto LOAD_AMOUNT = (u64)5e+6;

template <typename T, usize Tcount>
auto scalarT() -> f64
{
    T arr1[Tcount]{};
    T arr2[Tcount]{};
    for (usize i = 0; i < sizeof(T) * Tcount; i++) {
        ((u8*)&arr1)[i] = 0x55;
        ((u8*)&arr2)[i] = 0x55;
    }
    asm volatile("" ::"r"(&arr1), "r"(&arr2) :);

    for (u64 load = 0; load < LOAD_AMOUNT; load++) {
#pragma unroll
        for (u64 i = 0; i < Tcount; i++) {
            arr1[i] += arr2[i];
            asm volatile("" ::: "memory");
        }
#pragma unroll
        for (u64 i = 0; i < Tcount; i++) {
            arr1[i] -= arr2[i];
            asm volatile("" ::: "memory");
        }
#pragma unroll
        for (u64 i = 0; i < Tcount; i++) {
            arr1[i] *= arr2[i];
            asm volatile("" ::: "memory");
        }
#pragma unroll
        for (u64 i = 0; i < Tcount; i++) {
            if constexpr (std::is_same_v<T, i64>) {
#ifdef __amd64__
                asm volatile(
                    "cqo;"
                    "idivq %[divisor]"
                    : "=a"(arr1[i])
                    : [dividend] "a"(arr1[i]), [divisor] "m"(arr2[i])
                    : "cc");
#else
                arr1[i] /= arr2[i];
#endif
            } else {
                arr1[i] /= arr2[i];
            }
            asm volatile("" ::: "memory");
        }
    }

    return Tcount * LOAD_AMOUNT * 4 / 1e+6;
}

extern "C" auto c_scalarINT64() -> f64
{
    return scalarT<i64, 8>();
}

extern "C" auto c_scalarINT32() -> f64
{
    return scalarT<i32, 16>();
}

extern "C" auto c_scalarINT16() -> f64
{
    return scalarT<i16, 32>();
}

extern "C" auto c_scalarFP64() -> f64
{
    return scalarT<f64, 8>();
}

extern "C" auto c_scalarFP32() -> f64
{
    return scalarT<f32, 16>();
}

extern "C" auto c_scalarFP16() -> f64
{
    return scalarT<f16, 32>();
}

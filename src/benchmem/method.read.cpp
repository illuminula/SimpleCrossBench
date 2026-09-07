#include "../shared/z_style.hpp"

template <typename T>
__attribute__((no_builtin)) auto readT(u8* mem_block, usize mem_block_size) -> f64
{
    T v{};

#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size / sizeof(T); i++)
        v ^= ((TVec*)mem_block)[i];

    volatile T anti_o2 = v;
    return (mem_block_size >> 20) / 1024.0;
}

extern "C" auto c_memReadINT8(u8* mem_block, usize mem_block_size) -> f64
{
    return readT<at_Vector(1, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memReadINT32(u8* mem_block, usize mem_block_size) -> f64
{
    return readT<at_Vector(4, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memReadINT64(u8* mem_block, usize mem_block_size) -> f64
{
    return readT<at_Vector(8, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memReadINT256(u8* mem_block, usize mem_block_size) -> f64
{
    return readT<at_Vector(32, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memReadINT1024(u8* mem_block, usize mem_block_size) -> f64
{
    return readT<at_Vector(128, i8)>(mem_block, mem_block_size);
}

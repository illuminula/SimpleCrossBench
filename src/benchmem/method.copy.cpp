#include "../shared/z_style.hpp"

template <typename T>
__attribute__((no_builtin)) auto copyT(u8* mem_block1, u8* mem_block2, usize mem_block_size) -> f64
{
#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size / sizeof(T); i++)
        ((T*)mem_block1)[i] = ((T*)mem_block2)[i];

    return (mem_block_size >> 20) * 2 / 1024.0;
}

extern "C" auto c_memCopyINT8(u8* mem_block1, u8* mem_block2, usize mem_block_size) -> f64
{
    return copyT<at_Vector(1, i8)>(mem_block1, mem_block2, mem_block_size);
}

extern "C" auto c_memCopyINT32(u8* mem_block1, u8* mem_block2, usize mem_block_size) -> f64
{
    return copyT<at_Vector(4, i8)>(mem_block1, mem_block2, mem_block_size);
}

extern "C" auto c_memCopyINT64(u8* mem_block1, u8* mem_block2, usize mem_block_size) -> f64
{
    return copyT<at_Vector(8, i8)>(mem_block1, mem_block2, mem_block_size);
}

extern "C" auto c_memCopyINT256(u8* mem_block1, u8* mem_block2, usize mem_block_size) -> f64
{
    return copyT<at_Vector(32, i8)>(mem_block1, mem_block2, mem_block_size);
}

extern "C" auto c_memCopyINT1024(u8* mem_block1, u8* mem_block2, usize mem_block_size) -> f64
{
    return copyT<at_Vector(128, i8)>(mem_block1, mem_block2, mem_block_size);
}

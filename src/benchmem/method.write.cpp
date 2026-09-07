#include "../shared/z_style.hpp"

template <typename T>
__attribute__((no_builtin)) auto writeT(u8* mem_block, usize mem_block_size) -> void
{
    T v;
    for (usize i = 0; i < sizeof(v); i++)
        ((u8*)&v)[i] = 0x55;

#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size / sizeof(T); i++)
        ((T*)mem_block)[i] = v;
}

extern "C" auto c_memWriteINT8(u8* mem_block, usize mem_block_size) -> void
{
    writeT<at_Vector(1, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memWriteINT32(u8* mem_block, usize mem_block_size) -> void
{
    writeT<at_Vector(4, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memWriteINT64(u8* mem_block, usize mem_block_size) -> void
{
    writeT<at_Vector(8, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memWriteINT256(u8* mem_block, usize mem_block_size) -> void
{
    writeT<at_Vector(32, i8)>(mem_block, mem_block_size);
}

extern "C" auto c_memWriteINT1024(u8* mem_block, usize mem_block_size) -> void
{
    writeT<at_Vector(128, i8)>(mem_block, mem_block_size);
}

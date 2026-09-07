#include "../shared/z_style.hpp"

__attribute__((no_builtin)) extern "C" auto c_memLatencyRAR(u8* mem_block, usize mem_block_size) -> usize
{
    usize step_size = 4096;
    usize ops       = 0;

#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size; i += step_size) {
        volatile auto v = mem_block[i];
        // step_size++;
        ops++;
    }

    return ops;
}

__attribute__((no_builtin)) extern "C" auto c_memLatencyWAR(u8* mem_block, usize mem_block_size) -> usize
{
    usize step_size = 4096;
    usize ops       = 0;

#pragma clang loop unroll(disable)
    for (usize i = 0; i < mem_block_size; i += step_size) {
        mem_block[i]    = 0xAA;
        volatile auto v = (volatile u8&)mem_block[i];
        // step_size++;
        ops++;
    }

    return ops;
}

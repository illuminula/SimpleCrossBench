using i8    = char;
using i16   = short;
using i32   = int;
using i64   = long long;
using u8    = unsigned char;
using u16   = unsigned short;
using u32   = unsigned int;
using u64   = unsigned long long;
using usize = unsigned long;
using f16   = _Float16;
using f32   = float;
using f64   = double;

#define at_Vector(width, element_type) __attribute__((vector_size(width))) element_type

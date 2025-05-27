pub fn cIntToU32(n: c_int) u16 {
    return @intCast(n);
}

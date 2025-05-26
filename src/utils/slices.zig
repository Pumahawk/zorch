pub fn fill(buf: []u8, f: [] const u8) []u8 {
    for (f, 0..) |c, i| {
        if (i < buf.len) {
            buf[i] = c;
        } else {
            return buf[0..i];
        }
    }
    return buf[0..f.len];
}

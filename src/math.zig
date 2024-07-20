const std = @import("std");

pub fn vec2(x: i32, y: i32) Vec2 {
    return Vec2{ .x = x, .y = y };
}

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn dot(self: Vec2, other: Vec2) f32 {
        return self.x * other.x + self.y * other.y;
    }
};

pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return Vec3{ .x = x, .y = y, .z = z };
}

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
    }
};

pub fn vec4(x: f32, y: f32, z: f32, w: f32) Vec4 {
    return Vec4{ .x = x, .y = y, .z = z, .w = w };
}

pub const Vec4 = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub fn add(self: Vec4, other: Vec4) Vec4 {
        return Vec4{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z, .w = self.w + other.w };
    }

    pub fn to_vec3(self: Vec4) Vec3 {
        return vec3(self.x, self.y, self.z);
    }
};

pub const Mat4 = extern struct {
    fields: [4][4]f32,

    pub const zero = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
        },
    };

    /// identitiy matrix
    pub const identity = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 1, 0, 0, 0 },
            [4]f32{ 0, 1, 0, 0 },
            [4]f32{ 0, 0, 1, 0 },
            [4]f32{ 0, 0, 0, 1 },
        },
    };

    pub fn mul(self: Mat4, other: Mat4) Mat4 {
        var result: Mat4 = Mat4.zero;
        inline for (0..4) |row| {
            inline for (0..4) |col| {
                inline for (0..4) |i| {
                    result.fields[row][col] += self.fields[row][i] * other.fields[i][col];
                }
            }
        }
        return result;
    }

    pub fn apply(self: Mat4, vec: Vec4) Vec4 {
        var result = Vec4{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 0.0 };
        result.x = self.fields[0][0] * vec.x + self.fields[0][1] * vec.y + self.fields[0][2] * vec.z + self.fields[0][3] * vec.w;
        result.y = self.fields[1][0] * vec.x + self.fields[1][1] * vec.y + self.fields[1][2] * vec.z + self.fields[1][3] * vec.w;
        result.z = self.fields[2][0] * vec.x + self.fields[2][1] * vec.y + self.fields[2][2] * vec.z + self.fields[2][3] * vec.w;
        result.w = self.fields[3][0] * vec.x + self.fields[3][1] * vec.y + self.fields[3][2] * vec.z + self.fields[3][3] * vec.w;
        return result;
    }

    pub fn create_rotation_around_x(angle: f32) Mat4 {
        const sin = @sin(angle);
        const cos = @cos(angle);

        var mat = Mat4.identity;
        mat.fields[1][1] = cos;
        mat.fields[2][1] = sin;

        mat.fields[1][2] = -sin;
        mat.fields[2][2] = cos;

        return mat;
    }

    pub fn create_rotation_around_y(angle: f32) Mat4 {
        const sin = @sin(angle);
        const cos = @cos(angle);

        var mat = Mat4.identity;
        mat.fields[0][0] = cos;
        mat.fields[2][0] = sin;

        mat.fields[0][2] = -sin;
        mat.fields[2][2] = cos;

        return mat;
    }

    pub fn create_translate_mat(vec: Vec3) Mat4 {
        var mat = Mat4.identity;
        mat.fields[0][3] = vec.x;
        mat.fields[1][3] = vec.y;
        mat.fields[2][3] = vec.z;
        return mat;
    }

    pub fn format(value: Mat4, comptime _: []const u8, _: std.fmt.FormatOptions, stream: anytype) !void {
        try stream.writeAll("mat4{");

        inline for (0..4) |i| {
            const row = value.fields[i];
            try stream.print(" ({d:.2} {d:.2} {d:.2} {d:.2})", .{ row[0], row[1], row[2], row[3] });
        }

        try stream.writeAll(" }");
    }
};

pub fn to_radians(deg: f32) f32 {
    return std.math.pi * deg / 180.0;
}

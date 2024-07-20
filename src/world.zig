const std = @import("std");
const common = @import("common.zig");

const math = @import("math.zig");
const Vec2 = math.Vec2;
const vec2 = math.vec2;

const render = @import("render.zig");

pub const BLOCK_SIZE = 1.0;
pub const CHUNK_SIZE = 16;
pub const BLOCKS_IN_CHUNK = CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE;

pub const Block = enum {
    EMPTY,
    STONE,
    GRASS,
    WATER,
    WOOD,
    LEAVES,
    SAND,
    COUNT,
};

pub const Chunk = struct {
    blocks: [BLOCKS_IN_CHUNK]Block = [BLOCKS_IN_CHUNK]**Block.EMPTY,
    voxel_object: render.VoxelObject,
};

pub const World = struct {
    x_size: i32 = 0,
    y_size: i32 = 0,
    z_size: i32 = 0,
    chunks: std.ArrayList(Chunk),

    pub fn init(x_size: i32, y_size: i32, z_size: i32) World {
        return World{
            .x_size = x_size,
            .y_size = y_size,
            .z_size = z_size,
            .chunks = std.ArrayList(Chunk).init(common.allocator),
        };
    }

    pub fn deinit(self: World) void {
        self.chunks.deinit();
    }

    pub fn chunk_out_bounds(self: World, x: i32, y: i32, z: i32) bool {
        return x < 0 or y < 0 or z < 0 or x >= self.x_size or y >= self.y_size or z >= self.z_size;
    }

    pub fn chunk_at(self: World, x: i32, y: i32, z: i32) ?*Chunk {
        if (self.chunk_out_bounds(x, y, z)) {
            return null;
        }
        return &self.chunks.items[z * self.x_size * self.y_size + y * self.x_size + x];
    }

    pub fn block_at(self: World, x: i32, y: i32, z: i32) ?Block {
        const chunk_x = x / CHUNK_SIZE;
        const chunk_y = y / CHUNK_SIZE;
        const chunk_z = z / CHUNK_SIZE;

        const chunk = self.chunk_at(chunk_x, chunk_y, chunk_z) orelse return null;

        const block_x = x % CHUNK_SIZE;
        const block_y = y % CHUNK_SIZE;
        const block_z = z % CHUNK_SIZE;

        return chunk.*.blocks[block_z * CHUNK_SIZE * CHUNK_SIZE + block_y * CHUNK_SIZE + block_x];
    }
};

fn interpolate(a0: f32, a1: f32, w: f32) f32 {
    return (a1 - a0) * w + a0;
}

// pub fn generate_voxel_objects(world: *World) void {

// }

pub fn generate_hills(world: *World, level: i32) void {
    const hill_size = CHUNK_SIZE * 2;
    const hills_x = world.x_size * CHUNK_SIZE / hill_size + 1;
    const hills_y = world.y_size * CHUNK_SIZE / hill_size + 1;

    const gradients = common.allocator.alloc(math.Vec2, hills_x * hills_y) orelse unreachable;
    for (gradients) |*gradient| {
        const r = common.random.float(f32);
        gradient.*.x = @cos(r);
        gradient.*.y = @sin(r);
    }

    for (0..world.*.x_size * CHUNK_SIZE) |x| {
        for (0..world.*.x_size * CHUNK_SIZE) |y| {
            const x0 = x - x % hill_size;
            const x1 = x0 + hill_size;
            const y0 = y - y % hill_size;
            const y1 = y0 + hill_size;

            const sx = (x - x0) / @as(f32, @floatFromInt(hill_size));
            const sy = (y - y0) / @as(f32, @floatFromInt(hill_size));

            // Interpolate between grid point gradients
            var n0 = 0.0;
            var n1 = 0.0;

            n0 = gradients[x0 / hill_size * hills_y + y0 / hill_size].dot(vec2(sx, sy));
            n1 = gradients[x1 / hill_size * hills_y + y0 / hill_size].dot(vec2(sx - 1.0, sy));
            const ix0 = interpolate(n0, n1, sx);

            n0 = gradients[x0 / hill_size * hills_y + y1 / hill_size].dot(vec2(sx, sy - 1.0));
            n1 = gradients[x1 / hill_size * hills_y + y1 / hill_size].dot(vec2(sx - 1.0, sy - 1.0));
            const ix1 = interpolate(n0, n1, sx);

            const height = interpolate(ix0, ix1, sy) * 100.0;
            for (0..level + @as(i32, @intFromFloat(@min(height, 100.0)))) |z| {
                const block = world.get_block(x, y, level + z) orelse continue;
                block.* = Block.GRASS;
            }
        }
    }
}

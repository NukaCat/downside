const std = @import("std");

const common = @import("common.zig");
const world = @import("world.zig");

const gl = @cImport({
    @cInclude("GL/glew.h");
    @cInclude("GL/gl.h");
});

const png = @cImport({
    @cInclude("png.h");
});

const math = @import("math.zig");
const Mat4 = math.Mat4;
const Vec3 = math.Vec3;
const Vec4 = math.Vec4;
const to_radians = math.to_radians;
const vec3 = math.vec3;
const vec4 = math.vec4;

const SIDE_VERTEX_COUNT = 6;
const CUBE_SIDE_COUNT = 6;

pub const VERTEX_SIZE = 11;
// zig fmt: off
pub const default_cube_data = [_]f32{
    // vertex            texture pos   color            normal
    0.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, 0.0, 1.0,
    1.0, 0.0, 1.0,    1.0, 1.0,   0.0, 0.0, 0.0,   0.0, 0.0, 1.0,
    0.0, 1.0, 1.0,    0.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 1.0,
    0.0, 1.0, 1.0,    0.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 1.0,
    1.0, 0.0, 1.0,    1.0, 1.0,   0.0, 0.0, 0.0,   0.0, 0.0, 1.0,
    1.0, 1.0, 1.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, 1.0,

    0.0, 0.0, 0.0,    0.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, -1.0,
    0.0, 1.0, 0.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, 0.0, -1.0,
    1.0, 0.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, -1.0,
    1.0, 0.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 0.0, -1.0,
    0.0, 1.0, 0.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, 0.0, -1.0,
    1.0, 1.0, 0.0,    1.0, 1.0,   0.0, 0.0, 0.0,   0.0, 0.0, -1.0,

    1.0, 0.0, 0.0,    0.0, 0.0,   0.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    1.0, 1.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    1.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    1.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    1.0, 1.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   1.0, 0.0, 0.0,
    1.0, 1.0, 1.0,    1.0, 1.0,   0.0, 0.0, 0.0,   1.0, 0.0, 0.0,

    0.0, 0.0, 0.0,    0.0, 0.0,   0.0, 0.0, 0.0,   -1.0, 0.0, 0.0,
    0.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   -1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   -1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   -1.0, 0.0, 0.0,
    0.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   -1.0, 0.0, 0.0,
    0.0, 1.0, 1.0,    1.0, 1.0,   0.0, 0.0, 0.0,   -1.0, 0.0, 0.0,

    0.0, 1.0, 0.0,    0.0, 0.0,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    0.0, 1.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    1.0, 1.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    1.0, 1.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    0.0, 1.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0,
    1.0, 1.0, 1.0,    1.0, 1.0,   0.0, 0.0, 0.0,   0.0, 1.0, 0.0,

    0.0, 0.0, 0.0,    0.0, 0.0,   0.0, 0.0, 0.0,   0.0, -1.0, 0.0,
    1.0, 0.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, -1.0, 0.0,
    0.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, -1.0, 0.0,
    0.0, 0.0, 1.0,    0.0, 1.0,   0.0, 0.0, 0.0,   0.0, -1.0, 0.0,
    1.0, 0.0, 0.0,    1.0, 0.0,   0.0, 0.0, 0.0,   0.0, -1.0, 0.0,
    1.0, 0.0, 1.0,    1.0, 1.0,   0.0, 0.0, 0.0,   0.0, -1.0, 0.0,
};
// zig fmt: on

fn check_gl_err() void {
    const err = gl.glGetError();
    if (err != gl.GL_NO_ERROR) {
        std.debug.print("gl error {}\n", .{err});
        unreachable;
    }
}

pub const Voxel = struct {
    color_r: f32,
    color_g: f32,
    color_b: f32,
    texture_idx: u32,
};

pub const VoxelObject = struct {
    vao: u32,
    vbo: u32,
    vertex_count: u32,

    pub fn init(vertex_buffer: []const f32) VoxelObject {
        var object: VoxelObject = undefined;

        object.vertex_count = @intCast(vertex_buffer.len);

        gl.__glewGenVertexArrays.?(1, &object.vao);
        gl.__glewGenBuffers.?(1, &object.vbo);
        gl.__glewBindVertexArray.?(object.vao);

        gl.__glewBindBuffer.?(gl.GL_ARRAY_BUFFER, object.vbo);
        gl.__glewBufferData.?(gl.GL_ARRAY_BUFFER, @intCast(vertex_buffer.len * @sizeOf(f32)), @ptrCast(vertex_buffer.ptr), gl.GL_STATIC_DRAW);
        gl.__glewVertexAttribPointer.?(0, 3, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32) * 11, @ptrFromInt(@sizeOf(f32) * 0));
        gl.__glewVertexAttribPointer.?(1, 2, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32) * 11, @ptrFromInt(@sizeOf(f32) * 3));
        gl.__glewVertexAttribPointer.?(2, 3, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32) * 11, @ptrFromInt(@sizeOf(f32) * 5));
        gl.__glewVertexAttribPointer.?(3, 3, gl.GL_FLOAT, gl.GL_FALSE, @sizeOf(f32) * 11, @ptrFromInt(@sizeOf(f32) * 8));

        gl.__glewEnableVertexAttribArray.?(0);
        gl.__glewEnableVertexAttribArray.?(1);
        gl.__glewEnableVertexAttribArray.?(2);
        gl.__glewEnableVertexAttribArray.?(3);
        gl.__glewBindBuffer.?(gl.GL_ARRAY_BUFFER, 0);
        gl.__glewBindVertexArray.?(0);

        check_gl_err();
        return object;
    }

    pub fn deinit(self: VoxelObject) void {
        gl.__glewDeleteVertexArrays.?(1, &self.vao);
        gl.__glewDeleteBuffers.?(1, &self.vbo);
        check_gl_err();
    }
};

const Image = struct {
    data: []u8,
    width: u32,
    height: u32,
    allocator: std.mem.Allocator,

    pub fn init(width: u32, height: u32, allocator: std.mem.Allocator) Image {
        return Image{
            .width = width,
            .height = height,
            .data = allocator.alloc(u8, width * height * 4) catch unreachable,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Image) void {
        self.allocator.free(self.data);
    }
};

fn read_png(path: [:0]const u8, allocator: std.mem.Allocator) !Image {
    const file = png.fopen(path, "rb");
    defer if (png.fclose(file) != 0) unreachable;

    const read_struct = png.png_create_read_struct(png.PNG_LIBPNG_VER_STRING, null, null, null);
    if (read_struct == null) {
        return error.PNG_READ_ERROR;
    }

    const info = png.png_create_info_struct(read_struct);
    if (info == null) {
        return error.PNG_READ_ERROR;
    }

    png.png_init_io(read_struct, file);
    png.png_read_info(read_struct, info);

    const color_type = png.png_get_color_type(read_struct, info);
    const bit_depth = png.png_get_bit_depth(read_struct, info);

    if (bit_depth == 16) {
        png.png_set_strip_16(read_struct);
    }

    if (color_type == png.PNG_COLOR_TYPE_PALETTE) {
        png.png_set_palette_to_rgb(read_struct);
    }

    if (color_type == png.PNG_COLOR_TYPE_GRAY and bit_depth < 8) {
        png.png_set_expand_gray_1_2_4_to_8(read_struct);
    }

    if (png.png_get_valid(read_struct, info, png.PNG_INFO_tRNS) != 0) {
        png.png_set_tRNS_to_alpha(read_struct);
    }

    if (color_type == png.PNG_COLOR_TYPE_RGB or color_type == png.PNG_COLOR_TYPE_GRAY or color_type == png.PNG_COLOR_TYPE_PALETTE) {
        png.png_set_filler(read_struct, 0xFF, png.PNG_FILLER_AFTER);
        if (color_type == png.PNG_COLOR_TYPE_GRAY or color_type == png.PNG_COLOR_TYPE_GRAY_ALPHA) {
            png.png_set_gray_to_rgb(read_struct);
        }
    }

    png.png_read_update_info(read_struct, info);

    const width = png.png_get_image_width(read_struct, info);
    const height = png.png_get_image_height(read_struct, info);

    var img = Image.init(width, height, allocator);

    var row_pointers = std.ArrayList(*u8).init(common.allocator);
    defer row_pointers.deinit();
    row_pointers.resize(img.height) catch unreachable;

    for (0..img.height) |row| {
        row_pointers.items[row] = &img.data[row * img.width * 4];
    }
    png.png_read_image(read_struct, @ptrCast(row_pointers.items.ptr));

    return img;
}

fn load_shader(path: []const u8, gl_type: gl.GLenum) !u32 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var content = std.ArrayList(u8).init(common.allocator);
    defer content.deinit();

    try file.reader().readAllArrayList(&content, std.math.maxInt(usize));
    content.append(0) catch unreachable;

    const shader = gl.__glewCreateShader.?(gl_type);

    gl.__glewShaderSource.?(shader, 1, &@as([*c]u8, @ptrCast(@alignCast(content.items))), null);
    gl.__glewCompileShader.?(shader);

    var success: c_int = 0;
    gl.__glewGetShaderiv.?(shader, gl.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        var error_str: [512:0]u8 = undefined;
        gl.__glewGetShaderInfoLog.?(shader, error_str.len, null, @ptrCast(@alignCast(&error_str)));
        std.debug.print("shader compilation error: {s}", .{@as([*:0]const u8, &error_str)});
        return error.GlShaderCompilationError;
    }
    return shader;
}

pub const Camera = struct {
    horizontal_rotation: f32 = 0.0,
    vertical_rotation: f32 = 0.0,
    position: Vec3 = Vec3{ .x = 0, .y = 0, .z = 0 },

    pub fn rotate(self: *Camera, horizontal: f32, vertical: f32) void {
        self.*.vertical_rotation += vertical;
        self.*.horizontal_rotation += horizontal;
    }

    pub fn move(self: *Camera, vec: Vec3) void {
        const vert_rot = Mat4.create_rotation_around_x(to_radians(self.vertical_rotation));
        const hor_rot = Mat4.create_rotation_around_y(to_radians(-self.horizontal_rotation));

        const move_vec = hor_rot.mul(vert_rot).apply(vec4(vec.x, vec.y, vec.z, 1.0)).to_vec3();
        self.*.position = self.position.add(move_vec);
    }

    pub fn make_view_matrix(self: Camera) Mat4 {
        const vert_rot = Mat4.create_rotation_around_x(to_radians(-self.vertical_rotation));
        const hor_rot = Mat4.create_rotation_around_y(to_radians(self.horizontal_rotation));
        const translate_mat = Mat4.create_translate_mat(self.position);

        return (vert_rot.mul(hor_rot.mul(translate_mat)));
    }
};

pub const Scene = struct {
    voxel_objects: std.ArrayList(VoxelObject),

    pub fn init() Scene {
        return Scene{
            .voxel_objects = std.ArrayList(VoxelObject).init(common.allocator),
        };
    }

    pub fn deinit(self: Scene) void {
        self.voxel_objects.deinit();
    }
};

pub const Render = struct {
    shader_program: u32,
    atlas_texture: u32,
    atlas_block_width: f32,

    pub fn init() !Render {
        if (gl.glewInit() != gl.GLEW_OK) {
            return error.GlGlewInitError;
        }
        gl.glEnable(gl.GL_DEPTH_TEST);
        gl.glEnable(gl.GL_CULL_FACE);
        gl.glCullFace(gl.GL_FRONT);

        const vertex_shader = try load_shader("shaders/shader.vert", gl.GL_VERTEX_SHADER);
        const fragment_shader = try load_shader("shaders/shader.frag", gl.GL_FRAGMENT_SHADER);

        const shader_program = gl.__glewCreateProgram.?();

        var atlas_texture: u32 = 0;
        var atlas_block_width: f32 = 0;
        {
            gl.glGenTextures(1, &atlas_texture);
            gl.glBindTexture(gl.GL_TEXTURE_2D, atlas_texture);

            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT);
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT);
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST);
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST);

            const img = try read_png("img/blocks.png", common.allocator);
            defer img.deinit();

            gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGBA, @intCast(img.width), @intCast(img.height), 0, gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, img.data.ptr);
            atlas_block_width = @as(f32, @floatFromInt(img.height)) / @as(f32, @floatFromInt(img.width));
            gl.glBindTexture(gl.GL_TEXTURE_2D, 0);
        }

        gl.__glewAttachShader.?(shader_program, vertex_shader);
        gl.__glewAttachShader.?(shader_program, fragment_shader);
        gl.__glewLinkProgram.?(shader_program);

        var success: c_int = 0;
        gl.__glewGetProgramiv.?(shader_program, gl.GL_LINK_STATUS, &success);
        if (success == 0) {
            var error_str: [512:0]u8 = undefined;
            gl.__glewGetShaderInfoLog.?(shader_program, error_str.len, null, @ptrCast(@alignCast(&error_str)));
            std.debug.print("shader compilation error: {s}", .{@as([*:0]const u8, &error_str)});
            return error.GlShaderCompilationError;
        }

        return Render{
            .shader_program = shader_program,
            .atlas_texture = atlas_texture,
            .atlas_block_width = atlas_block_width,
        };
    }

    pub fn deinit() void {}

    pub fn render_frame(self: Render, scene: Scene, camera: Camera, width: u32, height: u32) void {
        gl.glViewport(0, 0, @intCast(width), @intCast(height));
        gl.glClearColor(135.0 / 256.0, 206.0 / 256.0, 235.0 / 256.0, 0.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);

        for (scene.voxel_objects.items) |voxel_object| {
            gl.__glewUseProgram.?(self.shader_program);
            gl.glBindTexture(gl.GL_TEXTURE_2D, self.atlas_texture);

            const light_dir_uniform = gl.__glewGetUniformLocation.?(self.shader_program, "light_dir");
            gl.__glewUniform3f.?(light_dir_uniform, 0.5, 0.5, -1);

            const view_pos_uniform = gl.__glewGetUniformLocation.?(self.shader_program, "view_pos");
            gl.__glewUniform3f.?(view_pos_uniform, 0.0, 0.0, 0.0);

            _ = @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height));
            const near_plane = 0.1;
            const far_plane = 1000.0;

            var projection = Mat4.zero;

            projection.fields[0][0] = 1.0;
            projection.fields[1][1] = 1.0;
            projection.fields[2][2] = (far_plane + near_plane) / (far_plane - near_plane);
            projection.fields[2][3] = -2.0 * (far_plane * near_plane) / (far_plane - near_plane);
            projection.fields[3][2] = 1;

            const view = camera.make_view_matrix();
            const model = Mat4.identity;
            const transform = projection.mul(view.mul(model));

            const transofrm_uniform = gl.__glewGetUniformLocation.?(self.shader_program, "transform");
            gl.__glewUniformMatrix4fv.?(transofrm_uniform, 1, gl.GL_TRUE, @ptrCast(&transform.fields));

            const model_uniform = gl.__glewGetUniformLocation.?(self.shader_program, "model");
            gl.__glewUniformMatrix4fv.?(model_uniform, 1, gl.GL_TRUE, @ptrCast(&model.fields));

            gl.__glewBindVertexArray.?(voxel_object.vao);
            gl.glDrawArrays(gl.GL_TRIANGLES, 0, @intCast(voxel_object.vertex_count));

            check_gl_err();
        }
    }
};

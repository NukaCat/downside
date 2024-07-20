const std = @import("std");

const gl = @cImport({
    @cInclude("GL/glew.h");
    @cInclude("GL/gl.h");
});

const sdl = @cImport({
    @cInclude("SDL3/sdl.h");
});

const math = @import("math.zig");
const Mat4 = math.Mat4;
const Vec3 = math.Vec3;
const Vec4 = math.Vec4;
const to_radians = math.to_radians;
const vec3 = math.vec3;
const vec4 = math.vec4;

const rend = @import("render.zig");
const world = @import("world.zig");

const InputState = struct {
    const KEYS_COUNT = 128;

    last_frame_mouse_move_x: f32 = 0.0,
    last_frame_mouse_move_y: f32 = 0.0,

    last_frame_quit: bool = false,

    last_frame_pressed_keys: [KEYS_COUNT]bool = [_]bool{false} ** KEYS_COUNT,
    pressed_keys: [KEYS_COUNT]bool = [_]bool{false} ** KEYS_COUNT,
};

pub fn update_input_state(input: *InputState) void {
    var new_input = InputState{};
    new_input.pressed_keys = input.*.pressed_keys;

    var event: sdl.SDL_Event = undefined;
    while (sdl.SDL_PollEvent(&event) == sdl.SDL_TRUE) {
        if (event.type == sdl.SDL_EVENT_QUIT) {
            new_input.last_frame_quit = true;
        }
        if (event.type == sdl.SDL_EVENT_KEY_UP and event.key.keysym.sym == sdl.SDLK_ESCAPE) {
            new_input.last_frame_quit = true;
        }
        if (event.type == sdl.SDL_EVENT_MOUSE_MOTION) {
            new_input.last_frame_mouse_move_x = event.motion.xrel;
            new_input.last_frame_mouse_move_y = event.motion.yrel;
        }
        if (event.type == sdl.SDL_EVENT_KEY_DOWN and event.key.keysym.sym < InputState.KEYS_COUNT) {
            new_input.pressed_keys[event.key.keysym.sym] = true;
        }
        if (event.type == sdl.SDL_EVENT_KEY_UP and event.key.keysym.sym < InputState.KEYS_COUNT) {
            new_input.pressed_keys[event.key.keysym.sym] = false;
            new_input.last_frame_pressed_keys[event.key.keysym.sym] = true;
        }
    }

    input.* = new_input;
}

pub fn main() !void {
    const result = sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_WINDOW_OPENGL);
    if (result != 0) {
        return error.SDLInitFailed;
    }
    defer sdl.SDL_Quit();

    const wind = sdl.SDL_CreateWindow("downside", 800, 600, sdl.SDL_WINDOW_OPENGL);
    defer sdl.SDL_DestroyWindow(wind);

    _ = sdl.SDL_SetRelativeMouseMode(sdl.SDL_TRUE);

    const sld_ctx = sdl.SDL_GL_CreateContext(wind);
    if (sld_ctx == null) {
        return error.SDLCreateCtxFail;
    }

    // const game_world = world.World.init(10, 10, 5);
    const render = try rend.Render.init();

    var cube_data = rend.default_cube_data;
    const vertex_count = cube_data.len / rend.VERTEX_SIZE;
    for (0..vertex_count) |i| {
        cube_data[i * rend.VERTEX_SIZE + 3] *= render.atlas_block_width;
    }

    const voxel_obj = rend.VoxelObject.init(&cube_data);
    defer voxel_obj.deinit();

    var scene = rend.Scene.init();
    defer scene.deinit();

    scene.voxel_objects.append(voxel_obj) catch unreachable;

    if (wind == null) {
        return error.SDLWindowCreateFailed;
    }

    var delta_time: f32 = 0.0;
    var frame_start: u64 = 0;

    var input = InputState{};

    var camera = rend.Camera{};

    while (true) {
        frame_start = sdl.SDL_GetTicks();

        update_input_state(&input);
        if (input.last_frame_quit) {
            break;
        }

        var move_vec = vec3(0.0, 0.0, 0.0);
        if (input.pressed_keys['a']) {
            move_vec.x += 0.1;
        }
        if (input.pressed_keys['d']) {
            move_vec.x -= 0.1;
        }
        if (input.pressed_keys['w']) {
            move_vec.z -= 0.1;
        }
        if (input.pressed_keys['s']) {
            move_vec.z += 0.1;
        }
        camera.move(move_vec);

        camera.rotate(input.last_frame_mouse_move_x, input.last_frame_mouse_move_y);

        render.render_frame(scene, camera, 800, 600);
        _ = sdl.SDL_GL_SwapWindow(wind);

        const frame_duration: u64 = sdl.SDL_GetTicks() - frame_start;
        delta_time = @as(f32, @floatFromInt(frame_duration)) / 1000.0;
        if (frame_duration < 16) {
            sdl.SDL_Delay(16 - @as(u32, @intCast(frame_duration)));
        }
    }
}

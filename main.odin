package main

import "core:fmt"
import "core:math"
import "core:time"

import rl "vendor:raylib"

main :: proc() {
        rl.SetTraceLogLevel(.WARNING)
        rl.SetConfigFlags({rl.ConfigFlags.WINDOW_RESIZABLE})
        rl.InitWindow(800, 450, "Handmade Hero")

        rl.InitAudioDevice()

        SAMPLE_RATE :: 48000
        BUFFER_FRAMES :: 2048
        CHANNELS :: 2

        rl.SetAudioStreamBufferSizeDefault(BUFFER_FRAMES)
        stream := rl.LoadAudioStream(SAMPLE_RATE, 16, CHANNELS)

        samples: [BUFFER_FRAMES * CHANNELS]i16
        phase: f64 = 0
        frequency: f64 = 256
        amplitude: f64 = 3000
        tau :: 2 * math.PI

        rl.PlayAudioStream(stream)

        offset_y: u8 = 0
        offset_x: u8 = 0

        pixels: []rl.Color
        texture: rl.Texture2D
        bitmap_width, bitmap_height: int

        previous_time := time.tick_now()
        previous_counter := time.read_cycle_counter()
        print_timing := true

        for !rl.WindowShouldClose() {
                if rl.IsKeyPressed(.SPACE) {
                        print_timing = !print_timing
                }

                for rl.IsAudioStreamProcessed(stream) {
                        for frame in 0..<BUFFER_FRAMES {
                                value := i16(math.sin(phase) * amplitude)
                                samples[frame * 2] = value     // Left
                                samples[frame * 2 + 1] = value // Right

                                phase += tau * frequency / SAMPLE_RATE
                                if phase >= tau {
                                        phase -= tau
                                }
                        }

                        rl.UpdateAudioStream(stream, &samples[0], BUFFER_FRAMES)
                }

                width := max(1, int(rl.GetScreenWidth()))
                height := max(1, int(rl.GetScreenHeight()))

                // Odin owns the pixels. Reallocate only when dimensions change.
                if width != bitmap_width || height != bitmap_height {
                        if texture.id != 0 {
                                rl.UnloadTexture(texture)
                        }
                        delete(pixels)
                        pixels = make([]rl.Color, width * height)
                        bitmap_width, bitmap_height = width, height

                        // This image borrows the slice; do not call UnloadImage on it.
                        bitmap := rl.Image{
                                data = raw_data(pixels),
                                width = i32(width),
                                height = i32(height),
                                mipmaps = 1,
                                format = .UNCOMPRESSED_R8G8B8A8,
                        }
                        texture = rl.LoadTextureFromImage(bitmap)
                }

                if rl.IsKeyDown(.W) {
                        offset_y -= 10
                }
                if rl.IsKeyDown(.A) {
                        offset_x -= 10
                }
                if rl.IsKeyDown(.S) {
                        offset_y += 10
                }
                if rl.IsKeyDown(.D) {
                        offset_x += 10
                }

                for y in 0..<height {
                        for x in 0..<width {
                                pixels[y * width + x] = rl.Color{
                                        0,                        // Red
                                        u8(y % 256) + offset_y,   // Green
                                        u8(x % 256) + offset_x,   // Blue
                                        255,                      // Alpha
                                }
                        }
                }
                rl.UpdateTexture(texture, raw_data(pixels))

                rl.BeginDrawing()
                rl.ClearBackground(rl.RAYWHITE)
                rl.DrawTexture(texture, 0, 0, rl.WHITE)
                rl.DrawFPS(10, 10)
                rl.EndDrawing()

                now_time := time.tick_now()
                now_counter := time.read_cycle_counter()
                elapsed := time.tick_diff(previous_time, now_time)
                
                milliseconds := f64(elapsed) / f64(time.Millisecond)
                if print_timing {
                        fmt.printf("Elapsed: %.3f ms | TSC ticks: %d\n", milliseconds, now_counter - previous_counter)
                }

                previous_time = now_time
                previous_counter = now_counter
        }
}

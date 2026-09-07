package main

import "core:fmt"
import "core:math"
import "core:time"

import rl "vendor:raylib"


main :: proc() {
	start := time.tick_now()

	rl.SetConfigFlags({rl.ConfigFlags.WINDOW_RESIZABLE})
	rl.InitWindow(800, 450, "Handmade Hero")

	elapsed := time.tick_since(start)
        milliseconds := f64(elapsed) / f64(time.Millisecond)

        fmt.printf("Elapsed: %.3f ms\n", milliseconds)

	rl.InitAudioDevice()

	rl.SetTargetFPS(144)

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

	for !rl.WindowShouldClose() {
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


		width := rl.GetScreenWidth()
		height := rl.GetScreenHeight()

		bitmap := rl.GenImageColor(width, height, rl.BLACK)

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

		pixels := cast([^]rl.Color)bitmap.data

		for y in 0..<height {
			for x in 0..<width {
				pixels[y * width + x] = rl.Color{
					0,           // Red
					u8(y % 256) + offset_y, // Green
					u8(x % 256) + offset_x, // Blue
					255,         // Alpha
				}
			}
		}

		texture := rl.LoadTextureFromImage(bitmap)

		rl.BeginDrawing()
			rl.ClearBackground(rl.RAYWHITE)
			rl.DrawTexture(texture, 0, 0, rl.WHITE)

			rl.DrawFPS(10, 10)
		rl.EndDrawing()

		rl.UnloadTexture(texture)
		rl.UnloadImage(bitmap)
	}
}
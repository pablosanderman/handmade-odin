package main

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({rl.ConfigFlags.WINDOW_RESIZABLE})
	rl.InitWindow(800, 450, "Handmade Hero")

	rl.SetTargetFPS(144)

	offset_y: u8 = 0
	offset_x: u8 = 0

	for !rl.WindowShouldClose() {
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

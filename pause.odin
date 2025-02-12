package main

import "core:strings"
import "core:time"
import "vendor:raylib"

pause :: proc() {
	b_size :: raylib.Vector2{128, 128}

	g_button :: raylib.Vector2{b_size.x + 30, WINDOW_HEIGHT - b_size.y - 10}
	g_rec :: raylib.Rectangle {
		x      = g_button.x,
		y      = g_button.y,
		width  = b_size.x,
		height = b_size.y,
	}


	q_button :: raylib.Vector2{g_button.x + b_size.x + 30, g_button.y}
	q_rec :: raylib.Rectangle {
		x      = q_button.x,
		y      = q_button.y,
		width  = b_size.x,
		height = b_size.y,
	}

	time.stopwatch_stop(glob.sw)

	time_str, score_str := data_to_cstring()

	m_pos := raylib.GetMousePosition()

	if raylib.IsMouseButtonReleased(.LEFT) {
		if raylib.CheckCollisionPointRec(m_pos, g_rec) {
			glob.scene = .Game
			return
		} else if raylib.CheckCollisionPointRec(m_pos, q_rec) {
			glob.scene = .Menu
			return
		}
	}

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)
	raylib.DrawTexture(glob.textures[ASSET_KEY[.game_bg]], 0, 0, raylib.WHITE)

	raylib.DrawTextureEx(glob.textures[ASSET_KEY[.play]], g_button, 0, 8, raylib.WHITE)
	raylib.DrawTextureEx(glob.textures[ASSET_KEY[.menu]], q_button, 0, 8, raylib.WHITE)

	raylib.DrawText(
		"TIME: ",
		(WINDOW_WIDTH / 2) - raylib.MeasureText("TIME: ", FONT_SIZE),
		500,
		FONT_SIZE,
		raylib.BLACK,
	)
	raylib.DrawText(time_str, (WINDOW_WIDTH / 2), 500, FONT_SIZE, raylib.BLACK)

	raylib.DrawText(
		"SCORE: ",
		(WINDOW_WIDTH / 2) - raylib.MeasureText("SCORE: ", FONT_SIZE),
		600,
		FONT_SIZE,
		raylib.BLACK,
	)
	raylib.DrawText(score_str, (WINDOW_WIDTH / 2), 600, FONT_SIZE, raylib.BLACK)
}

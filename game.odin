package main

import "core:strings"
import "core:time"
import "vendor:raylib"

game :: proc() {
	b_size :: raylib.Vector2{120, 120}

	p_button :: raylib.Vector2{10, WINDOW_HEIGHT - b_size.y - 10}
	p_rec :: raylib.Rectangle {
		x      = p_button.x,
		y      = p_button.y,
		width  = b_size.x,
		height = b_size.y,
	}

	time.stopwatch_start(glob.sw)

	time_str, score_str := data_to_cstring()

	m_pos := raylib.GetMousePosition()

	if raylib.IsMouseButtonReleased(.LEFT) {
		if raylib.CheckCollisionPointRec(m_pos, p_rec) {
			glob.scene = .Pause
		}
	}

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	raylib.DrawText(
		"TIME: ",
		(WINDOW_WIDTH / 2) - raylib.MeasureText("TIME: ", FONT_SIZE),
		10,
		FONT_SIZE,
		raylib.BLACK,
	)
	raylib.DrawText(time_str, (WINDOW_WIDTH / 2), 10, FONT_SIZE, raylib.BLACK)

	raylib.DrawText(
		"SCORE: ",
		WINDOW_WIDTH -
		raylib.MeasureText("SCORE: ", FONT_SIZE) -
		raylib.MeasureText(score_str, FONT_SIZE) -
		10,
		10,
		FONT_SIZE,
		raylib.BLACK,
	)
	raylib.DrawText(
		score_str,
		WINDOW_WIDTH - raylib.MeasureText(score_str, FONT_SIZE) - 10,
		10,
		FONT_SIZE,
		raylib.BLACK,
	)

	when ODIN_DEBUG {
		if raylib.CheckCollisionPointRec(m_pos, p_rec) {
			raylib.DrawRectangleRec(p_rec, reduce_alpha(raylib.YELLOW))
		} else {
			raylib.DrawRectangleRec(p_rec, reduce_alpha(raylib.GRAY))
		}
		raylib.DrawText(
			"||",
			auto_cast p_button.x + 5,
			auto_cast p_button.y + 5,
			FONT_SIZE * 2,
			reduce_alpha(raylib.BLACK),
		)

		if raylib.IsMouseButtonDown(.LEFT) {
			raylib.DrawCircleV(m_pos, 40, reduce_alpha(raylib.ORANGE))
		} else if raylib.IsMouseButtonDown(.RIGHT) {
			raylib.DrawCircleV(m_pos, 40, reduce_alpha(raylib.PURPLE))
		} else {
			raylib.DrawCircleV(m_pos, 40, reduce_alpha(raylib.GRAY))
		}

		raylib.DrawText("GAME", 0, 0, 100, reduce_alpha(raylib.PURPLE))
	}
}

package main

import "core:strings"
import "core:time"
import "vendor:raylib"

menu :: proc() {
	b_size :: raylib.Vector2{500, 80}

	g_button :: raylib.Vector2{(WINDOW_WIDTH / 2) - 250, 480 + 120 * 1}
	g_rec :: raylib.Rectangle {
		x      = g_button.x,
		y      = g_button.y,
		width  = b_size.x,
		height = b_size.y,
	}


	q_button :: raylib.Vector2{(WINDOW_WIDTH / 2) - 250, 480 + 120 * 2}
	q_rec :: raylib.Rectangle {
		x      = q_button.x,
		y      = q_button.y,
		width  = b_size.x,
		height = b_size.y,
	}

	m_pos := raylib.GetMousePosition()

	if raylib.IsMouseButtonReleased(.LEFT) {
		if raylib.CheckCollisionPointRec(m_pos, g_rec) {
			glob.scene = .Game
		} else if raylib.CheckCollisionPointRec(m_pos, q_rec) {
			glob.scene = .Quit
		}
	}

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	when ODIN_DEBUG {
		if raylib.CheckCollisionPointRec(m_pos, g_rec) {
			raylib.DrawRectangleRec(g_rec, raylib.LIME)
		} else {
			raylib.DrawRectangleRec(g_rec, raylib.GRAY)
		}
		raylib.DrawText(
			"PLAY",
			auto_cast g_button.x + 150,
			auto_cast g_button.y + 5,
			FONT_SIZE * 2,
			raylib.BLACK,
		)

		if raylib.CheckCollisionPointRec(m_pos, q_rec) {
			raylib.DrawRectangleRec(q_rec, raylib.RED)
		} else {
			raylib.DrawRectangleRec(q_rec, raylib.GRAY)
		}
		raylib.DrawText(
			"QUIT",
			auto_cast q_button.x + 150,
			auto_cast q_button.y + 5,
			FONT_SIZE * 2,
			raylib.BLACK,
		)

		if raylib.IsMouseButtonDown(.LEFT) {
			raylib.DrawCircleV(m_pos, 40, raylib.ORANGE)
		} else if raylib.IsMouseButtonDown(.RIGHT) {
			raylib.DrawCircleV(m_pos, 40, raylib.PURPLE)
		} else {
			raylib.DrawCircleV(m_pos, 40, raylib.GRAY)
		}

		raylib.DrawText("MENU", 0, 0, 100, raylib.PURPLE)
	}
}

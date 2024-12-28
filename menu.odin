package main

import "core:math"
import "core:strings"
import "core:time"
import "vendor:raylib"

menu :: proc() {
	b_size :: raylib.Vector2{512, 128}

	g_button :: raylib.Vector2{(WINDOW_WIDTH - b_size.x) / 2, 580}
	g_rec :: raylib.Rectangle {
		x      = g_button.x,
		y      = g_button.y,
		width  = b_size.x,
		height = b_size.y,
	}


	q_button :: raylib.Vector2{(WINDOW_WIDTH - b_size.x) / 2, g_button.y + b_size.y + 30}
	q_rec :: raylib.Rectangle {
		x      = q_button.x,
		y      = q_button.y,
		width  = b_size.x,
		height = b_size.y,
	}

	p_button :: raylib.Vector2{10, WINDOW_HEIGHT - 130}
	p_rec :: raylib.Rectangle {
		x      = p_button.x,
		y      = p_button.y,
		width  = 120,
		height = 120,
	}

	m_pos := raylib.GetMousePosition()

	if raylib.IsMouseButtonReleased(.LEFT) {
		if raylib.CheckCollisionPointRec(m_pos, g_rec) {
			glob.scene = .Game
			return
		} else if raylib.CheckCollisionPointRec(m_pos, q_rec) {
			glob.scene = .Quit
			return
		} else if raylib.CheckCollisionPointRec(m_pos, p_rec) {
			raylib.ToggleFullscreen()
		}
	}

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	raylib.DrawTextureEx(glob.textures[ASSET_KEY[.label]], g_button, 0, 8, raylib.WHITE)
	raylib.DrawText(
		"PLAY",
		i32(g_button.x + (b_size.x - auto_cast raylib.MeasureText("PLAY", FONT_SIZE)) / 2),
		i32(g_button.y + math.floor(b_size.y / 4)),
		FONT_SIZE,
		raylib.BLACK,
	)
	raylib.DrawTextureEx(glob.textures[ASSET_KEY[.label]], q_button, 0, 8, raylib.WHITE)
	raylib.DrawText(
		"QUIT",
		i32(q_button.x + (b_size.x - auto_cast raylib.MeasureText("QUIT", FONT_SIZE)) / 2),
		i32(q_button.y + math.floor(b_size.y / 4)),
		FONT_SIZE,
		raylib.BLACK,
	)

	when ODIN_DEBUG {
		if raylib.CheckCollisionPointRec(m_pos, g_rec) {
			raylib.DrawRectangleRec(g_rec, reduce_alpha(raylib.LIME))
		} else {
			raylib.DrawRectangleRec(g_rec, reduce_alpha(raylib.GRAY))
		}

		if raylib.CheckCollisionPointRec(m_pos, q_rec) {
			raylib.DrawRectangleRec(q_rec, reduce_alpha(raylib.RED))
		} else {
			raylib.DrawRectangleRec(q_rec, reduce_alpha(raylib.GRAY))
		}
		raylib.DrawText(
			"QUIT",
			auto_cast q_button.x + 150,
			auto_cast q_button.y + 5,
			FONT_SIZE * 2,
			reduce_alpha(raylib.BLACK),
		)

		if raylib.CheckCollisionPointRec(m_pos, p_rec) {
			raylib.DrawRectangleRec(p_rec, reduce_alpha(raylib.BLUE))
		} else {
			raylib.DrawRectangleRec(p_rec, reduce_alpha(raylib.GRAY))
		}
		raylib.DrawText(
			raylib.IsWindowFullscreen() ? "[X]" : "[ ]",
			auto_cast p_button.x + 5,
			auto_cast p_button.y + 5,
			FONT_SIZE * 2,
			reduce_alpha(raylib.BLACK),
		)
		raylib.DrawText(
			"FULLSCREEN (at your own risk)",
			auto_cast (p_button.x + 125),
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

		raylib.DrawText("MENU", 0, 0, 100, reduce_alpha(raylib.PURPLE))
	}
}

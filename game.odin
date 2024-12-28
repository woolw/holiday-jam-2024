package main

import "core:strings"
import "core:time"
import "vendor:raylib"

game :: proc() {
	b_size :: raylib.Vector2{128, 128}

	p_button :: raylib.Vector2{10, WINDOW_HEIGHT - b_size.y - 10}
	p_rec :: raylib.Rectangle {
		x      = p_button.x,
		y      = p_button.y,
		width  = b_size.x,
		height = b_size.y,
	}

	bed_size :: raylib.Vector2{256, 128}
	bed_pos :: raylib.Vector2{WINDOW_WIDTH - bed_size.x - 10, WINDOW_HEIGHT - bed_size.y - 10}
	bed_rec :: raylib.Rectangle {
		x      = bed_pos.x,
		y      = bed_pos.y,
		width  = bed_size.x,
		height = bed_size.y,
	}

	time.stopwatch_start(glob.sw)

	time_str, score_str := data_to_cstring()

	m_pos := raylib.GetMousePosition()

	if raylib.IsMouseButtonReleased(.LEFT) {
		if raylib.CheckCollisionPointRec(m_pos, p_rec) {
			glob.scene = .Pause
		} else if len(glob.patient_queue) > 0 && raylib.CheckCollisionPointRec(m_pos, bed_rec) {
			glob.patient_queue[0].cooldown = 0
			pop_front(&glob.patient_queue)
		}
	}

	for &m, i in glob.moles {
		if m.cooldown == 0 {
			m.cooldown = 1
			#partial switch m.state {
			case .cautious:
				m.state = .curious
			case .curious:
				m.state = .cautious
			case .queued:
				m.state = .curious
			}

			m.pos = get_pos_for_state(m.state, i)
		}

		if raylib.IsMouseButtonReleased(.LEFT) &&
		   raylib.CheckCollisionPointRec(m_pos, m.pos) &&
		   m.state != .queued {
			m.cooldown = 0
			if m.state == .curious {
				_, _, s := time.clock_from_stopwatch(glob.sw^)
				glob.score += s
			} else if m.state == .downed {
				m.cooldown = 1
				m.state = .queued
				append(&glob.patient_queue, &m)
			}
		} else if raylib.IsMouseButtonReleased(.RIGHT) &&
		   raylib.CheckCollisionPointRec(m_pos, m.pos) &&
		   m.state == .curious {
			m.cooldown = 1
			m.state = .downed
			glob.score -= 10
		}
	}

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	draw_mole: for &m in glob.moles {
		if len(glob.patient_queue) > 0 && &m == glob.patient_queue[0] {
			continue draw_mole
		}
		if m.state == .downed || m.state == .queued {
			raylib.DrawTextureEx(
				glob.textures[ASSET_KEY[.mole_hurt]],
				{m.pos.x, m.pos.y},
				0,
				8,
				raylib.WHITE,
			)
		} else {
			raylib.DrawTextureEx(
				glob.textures[ASSET_KEY[.mole]],
				{m.pos.x, m.pos.y},
				0,
				8,
				raylib.WHITE,
			)
		}
	}

	raylib.DrawTextureEx(glob.textures[ASSET_KEY[.pause]], p_button, 0, 8, raylib.WHITE)

	if len(glob.patient_queue) > 0 {
		raylib.DrawTextureEx(glob.textures[ASSET_KEY[.bed_occupied]], bed_pos, 0, 8, raylib.WHITE)
	} else {
		raylib.DrawTextureEx(glob.textures[ASSET_KEY[.bed_free]], bed_pos, 0, 8, raylib.WHITE)
	}

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
}

get_pos_for_state :: proc(ms: MOLE_STATE, i: int) -> raylib.Rectangle {
	#partial switch ms {
	case .curious:
		upshift := MOLE_POS[i]
		upshift.y -= 50
		return upshift
	case:
		return MOLE_POS[i]
	}
}

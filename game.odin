package main

import "core:math/rand"
import "core:strings"
import "core:time"
import "vendor:raylib"

pb_size :: raylib.Vector2{128, 128}

p_button :: raylib.Vector2{10, WINDOW_HEIGHT - pb_size.y - 10}
p_rec :: raylib.Rectangle {
	x      = p_button.x,
	y      = p_button.y,
	width  = pb_size.x,
	height = pb_size.y,
}

game_exit :: proc() -> bool {
	for m in glob.moles {
		if m.state == .cautious || m.state == .curious {
			return false
		}
	}

	return true
}

game :: proc() {
	if game_exit() {
		glob.scene = .Score
	}
	time.stopwatch_start(glob.sw)


	m_pos := raylib.GetMousePosition()

	game_misc(m_pos)
	dT := raylib.GetFrameTime()
	game_hammer(dT)
	game_moles(m_pos, dT)

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	draw_misc()
	draw_hammers()
	draw_moles()
}

game_misc :: proc(m_pos: raylib.Vector2) {
	if raylib.IsMouseButtonReleased(.LEFT) {
		if raylib.CheckCollisionPointRec(m_pos, p_rec) {
			glob.scene = .Pause
			return
		}
	}
}

game_hammer :: proc(dT: f32) {
	for &h in glob.hammers {
		h.cooldown -= dT
		if h.cooldown <= 0 {
			switch h.state {
			case .cooldown:
				h.cooldown = 1.5
				h.state = .ready
				t_pos := int(rand.float32() * auto_cast len(MOLE_POS))
				h.target = &glob.moles[t_pos]
			case .ready:
				h.cooldown = 1
				h.state = .struck

				#partial switch t in h.target {
				case ^Mole:
					if t.state == .curious {
						t.cooldown = 1
						t.state = .downed
						glob.score -= 10
					}
				}
			case .struck:
				h.cooldown = 2
				h.state = .cooldown
				h.target = nil
			}
		}
	}

	s := time.duration_seconds(glob.sw._accumulation)
	if len(glob.hammers) < len(glob.moles) && len(glob.hammers) - 1 < int(s / 15) {
		add_hammer()
	}
}

game_moles :: proc(m_pos: raylib.Vector2, dT: f32) {
	for &m, i in glob.moles {
		if m.state == .cautious ||
		   m.state == .curious ||
		   len(glob.patient_queue) > 0 && &m == glob.patient_queue[0] {
			m.cooldown -= dT
		}
		if m.cooldown <= 0 {
			m.cooldown = rand.float32() * 3 + 2
			#partial state_switch: switch m.state {
			case .cautious:
				for h in glob.hammers {
					if h.target == &m && h.state == .struck {
						m.cooldown += 0.5
						break state_switch
					}
				}
				m.state = .curious
			case .curious:
				m.state = .cautious
			case .queued:
				pop_front(&glob.patient_queue)
				m.state = .curious
			}
		}

		if raylib.IsMouseButtonReleased(.LEFT) && raylib.CheckCollisionPointRec(m_pos, m.pos) {
			if m.state == .curious {
				m.cooldown = 0

				_, _, s := time.clock_from_stopwatch(glob.sw^)
				for h in glob.hammers {
					if &m == h.target {
						glob.score += s
					}
				}
			} else if m.state == .downed {
				m.cooldown = rand.float32() * 3 + 2
				m.state = .queued
				append(&glob.patient_queue, &m)
			}
		}
	}
}

draw_misc :: proc() {
	raylib.DrawTextureEx(glob.textures[ASSET_KEY[.pause]], p_button, 0, 8, raylib.WHITE)

	time_str, score_str := data_to_cstring()
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

draw_hammers :: proc() {
	for h in glob.hammers {
		if h.target == nil {continue}
		t := h.target.?

		switch h.state {
		case .cooldown:
			continue
		case .ready:
			raylib.DrawRectangle(
				auto_cast t.pos.x + 14,
				auto_cast t.pos.y - 100,
				100,
				70,
				raylib.ORANGE,
			)
		case .struck:
			raylib.DrawRectangle(
				auto_cast t.pos.x + 14,
				auto_cast t.pos.y - 75,
				100,
				70,
				raylib.RED,
			)
		}
	}
}

draw_moles :: proc() {
	bed_size :: raylib.Vector2{256, 128}
	bed_pos :: raylib.Vector2{WINDOW_WIDTH - bed_size.x - 10, WINDOW_HEIGHT - bed_size.y - 10}
	bed_rec :: raylib.Rectangle {
		x      = bed_pos.x,
		y      = bed_pos.y,
		width  = bed_size.x,
		height = bed_size.y,
	}

	c_builder := strings.builder_make()
	defer strings.builder_destroy(&c_builder)
	draw_mole: for &m in glob.moles {
		cooldown_vis: if m.state != .downed {
			strings.builder_reset(&c_builder)
			strings.write_f32(&c_builder, m.cooldown, 'f')

			if m.state == .queued {break cooldown_vis}
			raylib.DrawText(
				strings.to_cstring(&c_builder),
				auto_cast m.pos.x,
				auto_cast (m.pos.y + m.pos.height),
				FONT_SIZE / 3,
				raylib.BLACK,
			)
		}

		if len(glob.patient_queue) > 0 && &m == glob.patient_queue[0] {
			raylib.DrawText(
				strings.to_cstring(&c_builder),
				auto_cast bed_pos.x,
				auto_cast (bed_pos.y - 30),
				FONT_SIZE / 3,
				raylib.GREEN,
			)

			continue draw_mole
		}
		if m.state == .queued {
			raylib.DrawText(
				"QUEUED",
				auto_cast m.pos.x,
				auto_cast (m.pos.y + m.pos.height),
				FONT_SIZE / 3,
				raylib.GREEN,
			)
		} else if m.state == .downed {
			raylib.DrawText(
				"DOWNED",
				auto_cast m.pos.x,
				auto_cast (m.pos.y + m.pos.height),
				FONT_SIZE / 3,
				raylib.RED,
			)
		}

		if m.state == .downed || m.state == .queued {
			raylib.DrawTextureEx(
				glob.textures[ASSET_KEY[.mole_hurt]],
				{m.pos.x, m.pos.y},
				0,
				8,
				raylib.WHITE,
			)
		} else if m.state == .cautious {
			raylib.DrawTextureEx(
				glob.textures[ASSET_KEY[.mole]],
				{m.pos.x, m.pos.y},
				0,
				8,
				raylib.WHITE,
			)
		} else {
			raylib.DrawTextureEx(
				glob.textures[ASSET_KEY[.mole_curious]],
				{m.pos.x, m.pos.y},
				0,
				8,
				raylib.WHITE,
			)
		}
	}


	if len(glob.patient_queue) > 0 {
		raylib.DrawTextureEx(glob.textures[ASSET_KEY[.bed_occupied]], bed_pos, 0, 8, raylib.WHITE)
	} else {
		raylib.DrawTextureEx(glob.textures[ASSET_KEY[.bed_free]], bed_pos, 0, 8, raylib.WHITE)
	}
}

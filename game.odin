package main

import "core:fmt"
import "core:mem"
import "core:strconv"
import "core:strings"
import "core:time"
import "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
FPS_LIMIT :: 120
FONT_SIZE :: 35

GAME_STATE :: enum {
	Quit,
	Menu,
	Game,
	Pause,
	Scores,
}
glob := GAME_STATE.Menu

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			} else {
				fmt.eprint("=== all allocations freed ===\n")
			}

			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			} else {
				fmt.eprint("=== no incorrect frees ===\n")
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	run()
}

check_state :: proc() {
	if raylib.IsKeyPressed(.ESCAPE) {
		if glob == .Menu {
			glob = .Quit
		} else if glob == .Game {
			glob = .Pause
		} else {
			glob = .Menu
		}
	} else if raylib.IsKeyPressed(.G) && (glob == .Menu || glob == .Pause) {
		glob = .Game
	} else if raylib.IsKeyPressed(.S) && glob == .Menu {
		glob = .Scores
	}
}

scores :: proc() {
	m_pos := raylib.GetMousePosition()

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	when ODIN_DEBUG {
		if raylib.IsMouseButtonDown(.LEFT) {
			raylib.DrawCircleV(m_pos, 40, raylib.ORANGE)
		} else if raylib.IsMouseButtonDown(.RIGHT) {
			raylib.DrawCircleV(m_pos, 40, raylib.PURPLE)
		} else {
			raylib.DrawCircleV(m_pos, 40, raylib.GRAY)
		}

		raylib.DrawText("SCORES", 0, 0, 100, raylib.PURPLE)
	}
}

pause :: proc(sw: ^time.Stopwatch) {
	time.stopwatch_stop(sw)

	m_pos := raylib.GetMousePosition()

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	when ODIN_DEBUG {
		if raylib.IsMouseButtonDown(.LEFT) {
			raylib.DrawCircleV(m_pos, 40, raylib.ORANGE)
		} else if raylib.IsMouseButtonDown(.RIGHT) {
			raylib.DrawCircleV(m_pos, 40, raylib.PURPLE)
		} else {
			raylib.DrawCircleV(m_pos, 40, raylib.GRAY)
		}

		raylib.DrawText("PAUSE", 0, 0, 100, raylib.PURPLE)
	}
}

game :: proc(sw: ^time.Stopwatch, builder: ^strings.Builder) {
	time.stopwatch_start(sw)

	dT := raylib.GetFrameTime()

	_, m, s := time.clock_from_stopwatch(sw^)

	strings.builder_reset(builder)
	strings.write_int(builder, m)
	strings.write_rune(builder, ':')
	strings.write_int(builder, s)

	time_str := strings.to_cstring(builder)

	m_pos := raylib.GetMousePosition()

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	when ODIN_DEBUG {
		if raylib.IsMouseButtonDown(.LEFT) {
			raylib.DrawCircleV(m_pos, 40, raylib.ORANGE)
		} else if raylib.IsMouseButtonDown(.RIGHT) {
			raylib.DrawCircleV(m_pos, 40, raylib.PURPLE)
		} else {
			raylib.DrawCircleV(m_pos, 40, raylib.GRAY)
		}

		raylib.DrawText("GAME", 0, 0, 100, raylib.PURPLE)
	}

	raylib.DrawText(
		time_str,
		(WINDOW_WIDTH - raylib.MeasureText(time_str, FONT_SIZE)) / 2,
		0,
		FONT_SIZE,
		raylib.BLACK,
	)
}

menu :: proc() {
	m_pos := raylib.GetMousePosition()

	raylib.BeginDrawing()
	defer raylib.EndDrawing()
	raylib.ClearBackground(raylib.WHITE)

	when ODIN_DEBUG {
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

run :: proc() {
	raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "DOWN BELOW!")
	defer raylib.CloseWindow()
	raylib.SetTargetFPS(FPS_LIMIT)
	raylib.SetExitKey(.END)

	// game stuff
	sw := time.Stopwatch{}
	time.stopwatch_reset(&sw)
	defer time.stopwatch_stop(&sw)

	builder, err := strings.builder_make_none()
	if err != nil {
		fmt.eprint(err)
	}
	defer strings.builder_destroy(&builder)


	menu_loop: for !raylib.WindowShouldClose() {
		check_state()

		switch glob {
		case .Menu:
			time.stopwatch_reset(&sw)
			menu()
		case .Game:
			game(&sw, &builder)
		case .Pause:
			pause(&sw)
		case .Scores:
			scores()
		case .Quit:
			break menu_loop
		}
	}
}

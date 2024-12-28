package main

import "core:fmt"
import "core:mem"
import "core:path/filepath"
import "core:strings"
import "core:time"
import "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
FPS_LIMIT :: 120
FONT_SIZE :: 70

GAME_SCENE :: enum {
	Quit,
	Menu,
	Game,
	Pause,
	Score,
}

ASSETS :: enum {
	menu,
	pause,
	play,
	label,
	bed_free,
	bed_occupied,
}

@(rodata)
ASSET_KEY := [ASSETS]string {
	.menu         = "assets/menu16.png",
	.pause        = "assets/pause16.png",
	.play         = "assets/play16.png",
	.label        = "assets/empty_label16.png",
	.bed_free     = "assets/hospital_bed_free.png",
	.bed_occupied = "assets/hospital_bed_closed.png",
}

GAME_STATE :: struct {
	scene:        GAME_SCENE,
	sw:           ^time.Stopwatch,
	t_builder:    ^strings.Builder,
	score:        int,
	s_builder:    ^strings.Builder,
	textures:     map[string]raylib.Texture2D,
	bed_occupied: bool,
}
glob := GAME_STATE {
	scene = GAME_SCENE.Menu,
}

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

run :: proc() {
	raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "DOWN BELOW!")
	defer raylib.CloseWindow()
	raylib.SetTargetFPS(FPS_LIMIT)
	raylib.SetExitKey(.END)

	// game stuff
	sw := time.Stopwatch{}
	defer time.stopwatch_stop(&sw)
	glob.sw = &sw

	tb, err := strings.builder_make_none()
	if err != nil {
		fmt.eprintln(err)
	}
	defer strings.builder_destroy(&tb)
	glob.t_builder = &tb

	sb, err2 := strings.builder_make_none()
	if err2 != nil {
		fmt.eprintln(err2)
	}
	defer strings.builder_destroy(&sb)
	glob.s_builder = &sb

	glob.textures = populate_assets()
	defer clear_assets(glob.textures)

	menu_loop: for !raylib.WindowShouldClose() {
		debug_fallback_navigation()

		switch glob.scene {
		case .Menu:
			time.stopwatch_reset(glob.sw)
			menu()
		case .Game:
			game()
		case .Pause:
			pause()
		case .Score:
			score()
		case .Quit:
			break menu_loop
		}
	}
}

debug_fallback_navigation :: proc() {
	when ODIN_DEBUG {
		if raylib.IsKeyPressed(.ESCAPE) {
			if glob.scene == .Menu {
				glob.scene = .Quit
			} else if glob.scene == .Game {
				glob.scene = .Pause
			} else {
				glob.scene = .Menu
			}
		} else if raylib.IsKeyPressed(.G) && (glob.scene == .Menu || glob.scene == .Pause) {
			glob.scene = .Game
		} else if raylib.IsKeyPressed(.S) && glob.scene == .Game {
			glob.scene = .Score
		}
	}
}

data_to_cstring :: proc() -> (timer_str: cstring, score_str: cstring) {
	ms := time.duration_milliseconds(time.stopwatch_duration(glob.sw^))
	s := int(ms / 1000) % 60
	m := int(ms / 60_000)

	strings.builder_reset(glob.t_builder)
	strings.write_int(glob.t_builder, m)
	strings.write_rune(glob.t_builder, ':')
	strings.write_int(glob.t_builder, s)
	strings.write_rune(glob.t_builder, ':')
	strings.write_int(glob.t_builder, int(ms) % 1000)
	timer_str = strings.to_cstring(glob.t_builder)

	strings.builder_reset(glob.s_builder)
	strings.write_int(glob.s_builder, glob.score)
	score_str = strings.to_cstring(glob.s_builder)

	return timer_str, score_str
}

reduce_alpha :: proc(c: raylib.Color) -> raylib.Color {
	return c - raylib.Color{0, 0, 0, 128}
}

populate_assets :: proc() -> map[string]raylib.Texture2D {
	assets := make(map[string]raylib.Texture2D)
	matches, err := filepath.glob("assets/*.png")
	if err != nil {
		fmt.eprintln(err)
	}
	for match in matches {
		assets[match] = raylib.LoadTexture(fmt.ctprintf("%s", match))
	}
	delete(matches)
	return assets
}

clear_assets :: proc(assets: map[string]raylib.Texture2D) {
	for path, tex in assets {
		delete(path)
		raylib.UnloadTexture(tex)
	}
	delete(assets)
}

package main

import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:mem"
import "core:path/filepath"
import "vendor:raylib"

WINDOW_WIDTH :: 1920
WINDOW_HEIGHT :: 1080
FPS_LIMIT :: 120

main :: proc() {
	when ODIN_DEBUG {
		context.logger = log.create_console_logger()

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

	game()
}

game :: proc() {
	raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "DOWN BELOW!")
	defer raylib.CloseWindow()
	raylib.SetTargetFPS(FPS_LIMIT)

	m_color := raylib.DARKBLUE
	for !raylib.WindowShouldClose() {
		dT := raylib.GetFrameTime()

		m_pos := raylib.GetMousePosition()
		if raylib.IsMouseButtonPressed(.LEFT) do m_color = raylib.MAROON
		else if raylib.IsMouseButtonPressed(.RIGHT) do m_color = raylib.LIME

		raylib.BeginDrawing()
		defer raylib.EndDrawing()
		raylib.ClearBackground(raylib.WHITE)

		raylib.DrawCircleV(m_pos, 40, m_color)
	}
}

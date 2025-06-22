return {
	"sphamba/smear-cursor.nvim",
	event = "VeryLazy", -- Fix capitalization of event name
	opts = {
		hide_target_hack = true,
		cursor_color = "#00bfff", -- Neon Blue (cleaner on dark themes)
		stiffness = 0.6, -- Snappier cursor
		trailing_stiffness = 0.15, -- Faster trail catch-up
		trailing_exponent = 3, -- Shorter trail
		gamma = 1.1, -- Slight contrast pop
	},
}

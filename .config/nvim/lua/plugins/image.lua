return {
	{
		"folke/snacks.nvim",
		opts = {
			image = {
				enabled = true,
				backend = "kitty", -- use Kitty terminal's image backend
				max_width = nil, -- fill the terminal width
				max_height = nil, -- fill the terminal height
				opacity = 100, -- fully opaque
				border = "rounded", -- nice rounded border
				position = "center", -- center the image in the terminal
				horizontal_padding = 2, -- padding for aesthetics
				vertical_padding = 1,
			},
		},
	},
}

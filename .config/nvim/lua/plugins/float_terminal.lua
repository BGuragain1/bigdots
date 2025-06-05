return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<c-\>]], -- Ctrl+\ toggles terminal
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				terminal_mappings = true,
				persist_size = true,
				direction = "float", -- float, vertical, horizontal, tab
				close_on_exit = true,
				shell = vim.o.shell,
			})

			-- Keymaps to toggle terminal manually (optional, since open_mapping is set)
			local opts = { noremap = true, silent = true }
			vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>ToggleTerm<CR>", opts)
			vim.api.nvim_set_keymap("t", "<leader>t", "<C-\\><C-n><cmd>ToggleTerm<CR>", opts)
		end,
	},
}

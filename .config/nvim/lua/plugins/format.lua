return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
			},

			-- Format on save
			format_on_save = function(bufnr)
				-- Disable autoformat for specific filetypes
				local ignore_filetypes = {}
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
		})
	end,
}

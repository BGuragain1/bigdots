return {
	"lazyvim/lazyvim",
	keys = {
		-- Normal mode: wrap word under cursor
		{ '<leader>"', 'ciw"<C-r>""<Esc>', mode = "n", desc = 'Wrap word with "' },
		{ "<leader>'", "ciw'<C-r>\"'<Esc>", mode = "n", desc = "Wrap word with '" },
		{ "<leader>(", 'ciw(<C-r>")<Esc>', mode = "n", desc = "Wrap word with ()" },
		{ "<leader>[", 'ciw[<C-r>"]<Esc>', mode = "n", desc = "Wrap word with []" },
		{ "<leader>{", 'ciw{<C-r>"}<Esc>', mode = "n", desc = "Wrap word with {}" },
		{ "<leader><", 'ciw<<C-r>"><Esc>', mode = "n", desc = "Wrap word with <>" },
		{ "<leader>`", 'ciw`<C-r>"`<Esc>', mode = "n", desc = "Wrap word with `" },

		-- Visual mode: wrap selected text (using 'c' to change selection)
		{ '<leader>"', 'c"<C-r>""<Esc>', mode = "v", desc = 'Wrap selection with "' },
		{ "<leader>'", "c'<C-r>\"'<Esc>", mode = "v", desc = "Wrap selection with '" },
		{ "<leader>(", 'c(<C-r>")<Esc>', mode = "v", desc = "Wrap selection with ()" },
		{ "<leader>[", 'c[<C-r>"]<Esc>', mode = "v", desc = "Wrap selection with []" },
		{ "<leader>{", 'c{<C-r>"}<Esc>', mode = "v", desc = "Wrap selection with {}" },
		{ "<leader><", 'c<<C-r>"><Esc>', mode = "v", desc = "Wrap selection with <>" },
		{ "<leader>`", 'c`<C-r>"`<Esc>', mode = "v", desc = "Wrap selection with `" },
	},
}

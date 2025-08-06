return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"jay-babu/mason-nvim-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dap_virtual_text = require("nvim-dap-virtual-text")
		local mason_dap = require("mason-nvim-dap")

		dap_virtual_text.setup({
			only_first_definition = true,
			all_references = false,
			highlight_changed_variables = true,
			commented = true,
		})

		mason_dap.setup({
			ensure_installed = { "python" },
			automatic_installation = true,
			handlers = {
				function(config)
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})

		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				pythonPath = function()
					return "/home/bigyan1/.pyenv/shims/python3"
				end,
			},
		}

		dapui.setup({
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.7 },
						{ id = "stacks", size = 0.3 },
					},
					size = 40,
					position = "left",
				},
				{
					elements = {
						{ id = "repl", size = 1.0 },
					},
					size = 10,
					position = "bottom",
				},
			},
		})

		vim.fn.sign_define("DapBreakpoint", { text = "🐞", texthl = "", linehl = "", numhl = "" })

		-- Open dap-ui automatically only when attaching or launching debug session
		dap.listeners.before.attach["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.launch["dapui_config"] = function()
			dapui.open()
		end

		-- REMOVE auto-close listeners so UI stays open even if debug session stops unexpectedly
		-- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
		-- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

		-- Debug keymaps
		vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
		vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
		vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step Over" })
		vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Step Out" })

		vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
		vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run Last" })

		-- Terminate AND close UI ONLY on <leader>dq
		vim.keymap.set("n", "<leader>dq", function()
			dap.terminate()
			dapui.close()
			-- Optionally disable virtual text here
			-- dap_virtual_text.disable()
		end, { desc = "Terminate" })

		vim.keymap.set("n", "<leader>db", dap.list_breakpoints, { desc = "List Breakpoints" })
		vim.keymap.set("n", "<leader>de", function()
			dap.set_exception_breakpoints({ "all" })
		end, { desc = "Set Exception Breakpoints" })

		-- Toggle dap-ui manually
		vim.keymap.set("n", "<leader>dui", dapui.toggle, { desc = "Toggle Dap UI" })
	end,
}

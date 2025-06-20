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

		-- Setup dap-virtual-text
		dap_virtual_text.setup()

		-- Setup Mason DAP
		mason_dap.setup({
			ensure_installed = { "python" },
			automatic_installation = true,
			handlers = {
				function(config)
					require("mason-nvim-dap").default_setup(config)
				end,
			},
		})

		-- Python configuration
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

		-- Setup DAP UI
		dapui.setup()

		vim.fn.sign_define("DapBreakpoint", { text = "🐞" })

		-- Auto open/close dapui
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		-- Keybindings
		vim.keymap.set("n", "<leader>dt", function()
			dap.toggle_breakpoint()
		end, { desc = "Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dc", function()
			dap.continue()
		end, { desc = "Continue" })
		vim.keymap.set("n", "<leader>di", function()
			dap.step_into()
		end, { desc = "Step Into" })
		vim.keymap.set("n", "<leader>do", function()
			dap.step_over()
		end, { desc = "Step Over" })
		vim.keymap.set("n", "<leader>du", function()
			dap.step_out()
		end, { desc = "Step Out" })
		vim.keymap.set("n", "<leader>dr", function()
			dap.repl.open()
		end, { desc = "Open REPL" })
		vim.keymap.set("n", "<leader>dl", function()
			dap.run_last()
		end, { desc = "Run Last" })
		vim.keymap.set("n", "<leader>dq", function()
			dap.terminate()
			dapui.close()
			dap_virtual_text.toggle()
		end, { desc = "Terminate" })
		vim.keymap.set("n", "<leader>db", function()
			dap.list_breakpoints()
		end, { desc = "List Breakpoints" })
		vim.keymap.set("n", "<leader>de", function()
			dap.set_exception_breakpoints({ "all" })
		end, { desc = "Set Exception Breakpoints" })
	end,
}

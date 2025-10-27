return {
	{
		-- Core Debug Adapter Protocol
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- VS Code–like UI
			"theHamsta/nvim-dap-virtual-text", -- Inline variable values
			"nvim-neotest/nvim-nio", -- Needed by dap-ui
			"mfussenegger/nvim-dap-python", -- Python debug adapter
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local dap_python = require("dap-python")

			-- Path to your Python executable (adjust if needed)
			dap_python.setup("/home/bigyan1/Desktop/Olive_Group/test_videos/.venv/bin/python3")

			-- Setup dap-ui and virtual text
			require("nvim-dap-virtual-text").setup()
			dapui.setup()

			-- Automatically open/close dap-ui
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Define VS Code–style red dot breakpoint
			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })

			-- === DAP Keymaps ===
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last Session" })
			vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Stop" })
		end,
	},
}

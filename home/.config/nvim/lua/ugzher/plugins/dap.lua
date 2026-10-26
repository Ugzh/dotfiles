local js_debug_path = vim.fn.expand("$HOME/vscode-js-debug/dist/src/dapDebugServer.js")

return {
	{
		"mfussenegger/nvim-dap",
		cond = function()
			return vim.uv.fs_stat(js_debug_path) ~= nil
		end,
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")

			require("nvim-dap-virtual-text").setup({})

			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = { js_debug_path, "${port}" },
				},
			}

			dap.adapters.node = function(callback, config)
				if config.type == "node" then
					config.type = "pwa-node"
				end
				callback(dap.adapters["pwa-node"])
			end

			local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
			for _, filetype in ipairs(js_filetypes) do
				dap.configurations[filetype] = {
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach to Node.js",
						port = 9229,
						address = "localhost",
						localRoot = vim.fn.getcwd(),
						remoteRoot = "/usr/src/app",
						cwd = vim.fn.getcwd(),
						sourceMaps = true,
						protocol = "inspector",
					},
					{
						type = "pwa-node",
						request = "launch",
						name = "Debug Jest Tests",
						program = "${workspaceFolder}/node_modules/jest/bin/jest.js",
						args = { "--runInBand", "--no-cache", "${relativeFile}" },
						cwd = "${workspaceFolder}",
						runtimeExecutable = "node",
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
						sourceMaps = true,
						skipFiles = { "<node_internals>/**" },
					},
				}
			end

			ui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
				controls = {
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
						disconnect = "⏏",
					},
				},
			})

			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Ajouter/retirer un point d'arrêt" })
			vim.keymap.set("n", "<leader>dg", dap.run_to_cursor, { desc = "Exécuter jusqu'au curseur" })
			vim.keymap.set("n", "<leader>de", function()
				ui.eval(nil, { enter = true })
			end, { desc = "Évaluer sous le curseur" })

			vim.keymap.set("n", "<F1>", dap.continue, { desc = "Débogage : continuer" })
			vim.keymap.set("n", "<F2>", dap.step_into, { desc = "Débogage : entrer" })
			vim.keymap.set("n", "<F3>", dap.step_over, { desc = "Débogage : avancer" })
			vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Débogage : sortir" })
			vim.keymap.set("n", "<F5>", dap.step_back, { desc = "Débogage : revenir" })
			vim.keymap.set("n", "<F13>", dap.restart, { desc = "Débogage : redémarrer" })

			dap.listeners.before.attach.dapui_config = ui.open
			dap.listeners.before.launch.dapui_config = ui.open
			dap.listeners.before.event_terminated.dapui_config = ui.close
			dap.listeners.before.event_exited.dapui_config = ui.close
		end,
	},
}

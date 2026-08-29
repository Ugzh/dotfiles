local M = {}

local last_task

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.WARN, { title = "Tâches" })
end

local function run(command, cwd, name)
	last_task = { command = command, cwd = cwd, name = name }
	Snacks.terminal.open(command, {
		cwd = cwd,
		win = { position = "bottom", height = 0.35 },
		interactive = true,
	})
end

local function gradle_root()
	return vim.fs.root(0, { "gradlew" })
end

local function gradle_task(task, args)
	local root = gradle_root()
	if not root then
		notify("Aucun wrapper Gradle trouvé")
		return
	end

	local command = { "./gradlew", task }
	vim.list_extend(command, args or {})
	run(command, root, "Gradle " .. task)
end

local function read_package_json(root)
	local ok, lines = pcall(vim.fn.readfile, root .. "/package.json")
	if not ok then
		return nil
	end

	local decoded, package = pcall(vim.json.decode, table.concat(lines, "\n"))
	return decoded and package or nil
end

local function package_context()
	local root = vim.fs.root(0, { "package.json" })
	if not root then
		notify("Aucun package.json trouvé")
		return nil
	end

	local package = read_package_json(root)
	if not package then
		notify("Le package.json est illisible", vim.log.levels.ERROR)
		return nil
	end

	local manager = "npm"
	if vim.uv.fs_stat(root .. "/pnpm-lock.yaml") then
		manager = "pnpm"
	elseif vim.uv.fs_stat(root .. "/yarn.lock") then
		manager = "yarn"
	elseif vim.uv.fs_stat(root .. "/bun.lock") or vim.uv.fs_stat(root .. "/bun.lockb") then
		manager = "bun"
	elseif type(package.packageManager) == "string" then
		manager = package.packageManager:match("^[^@]+") or manager
	end

	return { root = root, package = package, manager = manager }
end

local function package_script(script, extra_args)
	local context = package_context()
	if not context then
		return
	end

	if not context.package.scripts or not context.package.scripts[script] then
		notify("Le script « " .. script .. " » n'existe pas")
		return
	end

	local command = { context.manager, "run", script }
	if extra_args and #extra_args > 0 then
		table.insert(command, "--")
		vim.list_extend(command, extra_args)
	end
	run(command, context.root, context.manager .. " " .. script)
end

function M.select_package_script()
	local context = package_context()
	if not context then
		return
	end

	local scripts = vim.tbl_keys(context.package.scripts or {})
	table.sort(scripts)
	if #scripts == 0 then
		notify("Aucun script dans package.json")
		return
	end

	vim.ui.select(scripts, { prompt = "Script package.json" }, function(script)
		if script then
			package_script(script)
		end
	end)
end

function M.test_package()
	package_script("test")
end

function M.typecheck_package()
	local context = package_context()
	if not context then
		return
	end

	if context.package.scripts and context.package.scripts.typecheck then
		package_script("typecheck")
		return
	end

	local compiler = context.root .. "/node_modules/.bin/tsc"
	if not vim.uv.fs_stat(compiler) then
		notify("TypeScript n'est pas installé localement et aucun script « typecheck » n'existe")
		return
	end

	run({ compiler, "--noEmit" }, context.root, "tsc --noEmit")
end

function M.test_current_file()
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		notify("Le buffer courant n'est pas un fichier")
		return
	end

	local context = package_context()
	if not context then
		return
	end

	local relative = vim.fs.relpath(context.root, file)
	if not relative then
		notify("Le fichier courant n'appartient pas au package")
		return
	end

	if not context.package.scripts or not context.package.scripts.test then
		notify("Le script « test » n'existe pas")
		return
	end

	local command = { context.manager, "run", "test", "--", relative }
	run(command, context.root, context.manager .. " test " .. relative)
end

function M.test_current_kotlin_file()
	local file = vim.api.nvim_buf_get_name(0)
	if vim.bo.filetype ~= "kotlin" or file == "" then
		notify("Le buffer courant n'est pas un fichier Kotlin")
		return
	end

	local package_name
	for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, math.min(80, vim.api.nvim_buf_line_count(0)), false)) do
		package_name = line:match("^%s*package%s+([%w_.]+)")
		if package_name then
			break
		end
	end

	local class_name = vim.fs.basename(file):gsub("%.kt$", "")
	local test_name = package_name and (package_name .. "." .. class_name) or class_name
	gradle_task("test", { "--tests", test_name })
end

function M.rerun_last()
	if not last_task then
		notify("Aucune tâche à relancer")
		return
	end
	run(last_task.command, last_task.cwd, last_task.name)
end

vim.keymap.set("n", "<leader>kb", function()
	gradle_task("build")
end, { desc = "Gradle build" })
vim.keymap.set("n", "<leader>kt", function()
	gradle_task("test")
end, { desc = "Gradle test" })
vim.keymap.set("n", "<leader>kf", M.test_current_kotlin_file, { desc = "Tester le fichier Kotlin" })
vim.keymap.set("n", "<leader>kr", function()
	gradle_task("bootRun")
end, { desc = "Gradle bootRun" })
vim.keymap.set("n", "<leader>kc", function()
	gradle_task("clean")
end, { desc = "Gradle clean" })

vim.keymap.set("n", "<leader>rs", M.select_package_script, { desc = "Choisir un script package.json" })
vim.keymap.set("n", "<leader>rc", M.typecheck_package, { desc = "Vérifier les types du package" })
vim.keymap.set("n", "<leader>rt", M.test_package, { desc = "Tester le package" })
vim.keymap.set("n", "<leader>rf", M.test_current_file, { desc = "Tester le fichier courant" })
vim.keymap.set("n", "<leader>rl", M.rerun_last, { desc = "Relancer la dernière tâche" })

return M

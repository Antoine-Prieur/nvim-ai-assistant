local M = {}
local log_dir = vim.fn.stdpath("data") .. "nvim-logs-ai-assistant"

vim.fn.mkdir(log_dir, "p")

function M.log_api_call(prompt, response)
	local timestamp = os.date("%Y%m%d_%H%M%S")
	local filename = string.format("%s/api_call_%s.json", log_dir, timestamp)

	local log_entry = {
		timestamp = timestamp,
		prompt = prompt,
		response = response,
	}

	local file = io.open(filename, "w")
	if file then
		file:write(vim.fn.json_encode(log_entry))
		file:close()
	end
end

function M.setup_telescope()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local function format_display(entry)
		local date = os.date("%Y-%m-%d %H:%M", tonumber(entry.timestamp:match("(%d+)")))
		local truncated_prompt = entry.prompt:sub(1, 50)
		if #entry.prompt > 50 then
			truncated_prompt = truncated_prompt .. "..."
		end
		return string.format("%s | %s", date, truncated_prompt)
	end

	local function view_log_file(prompt_bufnr)
		local selection = action_state.get_selected_entry(prompt_bufnr)
		actions.close(prompt_bufnr)

		local content = vim.fn.readfile(selection.filename)
		local json_str = table.concat(content, "\n")
		local ok, parsed = pcall(vim.fn.json_decode, json_str)

		if ok and parsed.response then
			vim.cmd("vnew")
			local buf = vim.api.nvim_get_current_buf()
			local response_text = tostring(parsed.response)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(response_text, "\n"))
			vim.bo[buf].modifiable = false
			vim.bo[buf].buftype = "nofile"
		end
	end

	local api_previewer = previewers.new_buffer_previewer({
		title = "Response",
		define_preview = function(self, entry)
			local content = vim.fn.readfile(entry.filename)
			if #content > 0 then
				local json_str = table.concat(content, "\n")
				local ok, parsed = pcall(vim.fn.json_decode, json_str)

				if ok and parsed.response then
					local response_text = tostring(parsed.response)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(response_text, "\n"))
				end
			end
		end,
	})

	local function api_history()
		local files = vim.fn.glob(log_dir .. "/*.json", true, true)
		local entries = {}

		for _, file in ipairs(files) do
			local content = vim.fn.readfile(file)
			if #content > 0 then
				local ok, parsed = pcall(vim.fn.json_decode, table.concat(content, "\n"))
				if ok and parsed.prompt then
					table.insert(entries, {
						filename = file,
						display = parsed.prompt,
						ordinal = parsed.prompt,
						timestamp = parsed.timestamp,
						prompt = parsed.prompt,
					})
				end
			end
		end

		table.sort(entries, function(a, b)
			return a.timestamp > b.timestamp
		end)

		pickers
			.new({}, {
				prompt_title = "NVIM AI assistant history",
				finder = finders.new_table({
					results = entries,
					entry_maker = function(entry)
						return {
							filename = entry.filename,
							display = format_display(entry),
							ordinal = format_display(entry),
							prompt = entry.prompt,
						}
					end,
				}),
				previewer = api_previewer,
				attach_mappings = function(_, map)
					map("i", "<CR>", view_log_file)
					map("n", "<CR>", view_log_file)
					return true
				end,
			})
			:find()
	end

	vim.api.nvim_create_user_command("AIAssistantHistory", api_history, {})
end

return M

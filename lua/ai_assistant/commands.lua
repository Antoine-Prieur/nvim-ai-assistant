local M = {}

local api = require("ai_assistant.api")

M.make_request_input = function(api_key, model)
	local system = "Provide concise responses while maintaining accuracy and helpfulness."
	local prompt = vim.fn.input("Enter prompt: ")
	if prompt ~= "" then
		api.query_assistant(prompt, api_key, model, system)
	end
end

M.make_request_visual = function(prefix, api_key, model)
	local s_start = vim.fn.getpos("'<")
	local s_end = vim.fn.getpos("'>")
	local lines = vim.fn.getline(s_start[2], s_end[2])
	local system = [[When I ask you to update code, please show the changes using diff format in code blocks like this:

```diff
- old line of code
+ new line of code
Show only the changed lines with - and + prefixes, preserving indentation.]]

	if #lines == 0 then
		return
	end

	-- Convert single string to table if needed
	if type(lines) == "string" then
		lines = { lines }
	end

	lines[1] = string.sub(lines[1], s_start[3], -1)
	if #lines > 1 then
		lines[#lines] = string.sub(lines[#lines], 1, s_end[3])
	else
		lines[1] = string.sub(lines[1], 1, s_end[3])
	end

	local selected_text = table.concat(lines, "\n")
	local text = prefix and (prefix .. "\n\n" .. selected_text) or selected_text
	api.query_assistant(text, api_key, model, system)
end

M.make_request_input_visual = function(api_key, model)
	local prompt = vim.fn.input("Enter prompt: ")
	if prompt ~= "" then
		M.make_request_visual(prompt, api_key, model)
	end
end

return M

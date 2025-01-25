local M = {}

local ui = require("ai_assistant.ui")

local log = function(msg)
	vim.api.nvim_echo({ { msg, "Normal" } }, true, {})
end

local function get_curl_command(prompt, api_key, model)
	local json_data = vim.json.encode({
		model = model,
		max_tokens = 1000,
		temperature = 0,
		stream = true,
		messages = { {
			role = "user",
			content = prompt,
		} },
		system = "Provide concise responses while maintaining accuracy and helpfulness.",
	})

	return string.format(
		[[curl -X POST https://api.anthropic.com/v1/messages -H "x-api-key: %s" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" -d '%s']],
		api_key,
		json_data
	)
end

M.query_assistant = function(prompt, api_key, model)
	local buf = ui.create_response_buffer()
	local full_content = ""

	local function on_stdout(_, data)
		log("Received data chunk")
		for _, line in ipairs(data) do
			if line:match("^data: ") then
				local json_str = line:sub(6)
				if json_str ~= "[DONE]" then
					local success, response = pcall(vim.json.decode, json_str)
					if success and response.type == "content_block_delta" then
						full_content = full_content .. response.delta.text
						log("Scheduling buffer update")
						vim.schedule(function()
							log("Inside schedule callback")
							local lines = vim.split(full_content, "\n")
							vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
							log("Buffer updated")
						end)
					end
				end
			end
		end
	end

	local curl_cmd = get_curl_command(prompt, api_key, model)
	vim.fn.jobstart(curl_cmd, {
		on_stdout = on_stdout,
		stdout_buffered = false,
	})
end

return M

local M = {}

local api = require("ai_assistant.api")

-- Configuration with defaults
M.setup = function(opts)
	opts = opts or {}
	M.config = {
		api_key = opts.api_key,
		model = opts.model,
	}
end

M.test_query = function()
	local result = api.query_assistant("Write a hello world in lua, python and java", M.config.api_key, M.config.model)
end

M.test_query_streaming = function()
	local result = api.test_streaming()
end

vim.api.nvim_create_user_command("TestClaude", M.test_query, {})

return M

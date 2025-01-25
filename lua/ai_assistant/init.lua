local M = {}

local commands = require("ai_assistant.commands")
local history = require("ai_assistant.history")

-- Configuration with defaults
M.setup = function(opts)
	opts = opts or {}
	M.config = {
		api_key = opts.api_key,
		model = opts.model,
	}
end

vim.api.nvim_create_user_command("AskAIAssistant", function()
	commands.make_request_input(M.config.api_key, M.config.model)
end, {})

vim.api.nvim_create_user_command("AskAIAssistantVisual", function()
	commands.make_request_input_visual(M.config.api_key, M.config.model)
end, {})

history.setup_telescope()

return M

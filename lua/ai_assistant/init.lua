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

-- -- test_chatbot.lua
-- local Chat = require("ai_assistant.ui")
--
-- -- Create new chat instance
-- local chat = Chat.new()
-- chat:init()
--
-- -- Test multi-line message
-- chat:add_message("user", "Here's a multi-line message:\nLine 1\nLine 2\nLine 3")
--
-- -- Test code block
-- chat:add_message("assistant", "Here's some code:\n```lua\nlocal x = 42\nprint(x)\n```")
--
-- -- Test long message
-- chat:add_message("user", string.rep("This is a very long message that should wrap properly. ", 5))
--
-- -- Test special characters
-- chat:add_message("assistant", "Special chars: !@#$%^&*()")
--
-- -- Keep window open
-- vim.cmd([[autocmd VimLeavePre * lua vim.wait(500, function() return false end)]])
return M

local Chat = {}
local api = vim.api

Chat.create_response_buffer = function()
	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_name(buf, "Assistant Response")

	return buf
end

-- Configuration
local config = {
	buffer_name = "ChatBot",
	buffer_filetype = "chatbot",
	highlights = {
		ChatbotUser = { fg = "#89b4fa", bold = true }, -- Catppuccin blue
		ChatbotAssistant = { fg = "#a6e3a1", bold = true }, -- Catppuccin green
		ChatbotTimestamp = { fg = "#9399b2" }, -- Catppuccin overlay0
		ChatbotBorder = { fg = "#313244" }, -- Catppuccin surface0
	},
}

-- Create highlight groups
local function setup_highlights()
	for group, colors in pairs(config.highlights) do
		vim.api.nvim_set_hl(0, group, colors)
	end
end

local Chat = {}
Chat.__index = Chat

function Chat.new()
	local self = setmetatable({}, Chat)
	self.buffer = nil
	self.window = nil
	self.messages = {}
	return self
end

function Chat:create_buffer()
	-- Create a new buffer
	self.buffer = api.nvim_create_buf(false, true)
	vim.bo[self.buffer].buftype = "nofile"
	vim.bo[self.buffer].swapfile = false
	vim.bo[self.buffer].filetype = config.buffer_filetype

	-- Set buffer name
	api.nvim_buf_set_name(self.buffer, config.buffer_name)

	-- Create input buffer at the bottom
	self:setup_input_area()

	return self.buffer
end

function Chat:setup_input_area()
	local width = api.nvim_win_get_width(0)
	local separator = string.rep("─", width - 2)
	local lines = {
		"╭" .. separator .. "╮",
		"│" .. string.rep(" ", width - 2) .. "│",
		"╰" .. separator .. "╯",
	}

	local ns_id = api.nvim_create_namespace("chatbot")
	local start_line = api.nvim_buf_line_count(self.buffer)

	api.nvim_buf_set_lines(self.buffer, start_line, -1, false, lines)

	for i = 0, #lines - 1 do
		api.nvim_buf_add_highlight(self.buffer, ns_id, "ChatbotBorder", start_line + i, 0, -1)
	end
end

function Chat:add_message(role, content)
	local timestamp = os.date("%H:%M")
	local ns_id = api.nvim_create_namespace("chatbot")

	-- Format the message
	local prefix = role == "user" and "You" or "Assistant"
	local hl_group = role == "user" and "ChatbotUser" or "ChatbotAssistant"

	-- Add timestamp and role
	local header = string.format("[%s] %s:", timestamp, prefix)
	local lines = vim.split(content, "\n", { plain = true })

	-- Insert message before the input area
	local insert_point = #api.nvim_buf_get_lines(self.buffer, 0, -1, false) - 3
	local msg_lines = { header }
	for _, line in ipairs(lines) do
		table.insert(msg_lines, line)
	end
	table.insert(msg_lines, "")

	-- Apply highlighting
	api.nvim_buf_add_highlight(self.buffer, ns_id, hl_group, insert_point, string.len("[" .. timestamp .. "] "), -1)
	api.nvim_buf_add_highlight(
		self.buffer,
		ns_id,
		"ChatbotTimestamp",
		insert_point,
		0,
		string.len("[" .. timestamp .. "]")
	)

	-- Store message
	table.insert(self.messages, {
		role = role,
		content = content,
		timestamp = timestamp,
	})

	if self.window then
		local last_line = api.nvim_buf_line_count(self.buffer)
		api.nvim_win_set_cursor(self.window, { last_line - 3, 0 })
	end
end

function Chat:create_window()
	-- Calculate dimensions (80% of editor size)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	-- Calculate position (centered)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Window options
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	-- Create window
	self.window = api.nvim_open_win(self.buffer, true, opts)

	-- Set window-local options
	vim.wo[self.window].wrap = true
	vim.wo[self.window].linebreak = true
	vim.wo[self.window].number = false
	vim.wo[self.window].cursorline = false

	return self.window
end

-- Initialize chat interface
function Chat:init()
	setup_highlights()
	self:create_buffer()
	self:create_window()

	-- Add welcome message
	self:add_message("assistant", "Hello! How can I help you today?")
end

-- Example usage:
-- local chat = Chat.new()
-- chat:init()
--
-- -- Add messages
-- chat:add_message("user", "Hello!")
-- chat:add_message("assistant", "Hi there! How can I help you?")

return Chat

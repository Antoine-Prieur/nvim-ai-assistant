local M = {}

M.create_response_buffer = function()
	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_name(buf, "Assistant Response")

	return buf
end

return M

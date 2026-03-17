require("util")

local applicable_lsp_requests = {
	"angular/getComponentsWithTemplateFile",
	"angular/getTemplateLocationForComponent",
}

local buffer_cursor_memory = {}
local should_restore_cursor = false

local M = {}

local function getBufferName(buffer_id)
	local buffer_name = vim.api.nvim_buf_get_name(buffer_id)
	local endIndex = string.find(buffer_name, "/[^/]*$")
	if endIndex == nil then
		return nil
	end
	return string.sub(buffer_name, endIndex + 1)
end

local function getCursorPosition()
	local line_number = vim.fn.getpos(".")[2]
	local column = vim.fn.getpos(".")[3]
	return { line_number, column }
end

M.setup = function()
	vim.api.nvim_create_autocmd("LspRequest", {
		callback = function(args)
			local request = args.data.request

			for _, applicable_lsp_request in pairs(applicable_lsp_requests) do
				if request["method"]:endsWith(applicable_lsp_request) then
					should_restore_cursor = true
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufLeave", {
		callback = function()
			local buffer_name = getBufferName(vim.api.nvim_get_current_buf())
			if buffer_name == nil then
				return
			end

			local cursor_pos = getCursorPosition()
			buffer_cursor_memory[buffer_name] = cursor_pos
			-- vim.notify(
			-- 	"Saving cursor: " .. cursor_pos[1] .. " " .. cursor_pos[2] .. " for buffer: " .. buffer_name .. " BufferId: " .. vim.api.nvim_get_current_buf()
			-- )
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function()
			local buffer_name = getBufferName(vim.api.nvim_get_current_buf())
			if buffer_name == nil then
				return
			end

			local cursor_pos = buffer_cursor_memory[buffer_name]
			if cursor_pos == nil then
				return
			end

			vim.schedule(function()
				if should_restore_cursor then
					vim.fn.setcursorcharpos(cursor_pos[1], cursor_pos[2], 0)
					should_restore_cursor = false
				end
			end)
		end,
	})
end

return M

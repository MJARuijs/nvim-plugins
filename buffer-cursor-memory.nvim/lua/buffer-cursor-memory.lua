local M = {}

local buffer_cursor_memory = {}
local current_lsp_request = nil

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
			local bufnr = args.buf
			local client_id = args.data.client_id
			local request_id = args.data.request_id
			local request = args.data.request

			local message = "BufNr: " .. bufnr .. ". ClientId: " .. client_id .. ". RequestId: " .. request_id
			if request ~= nil then
				if request["type"] == "pending" then
					current_lsp_request = request["method"]
				else
					current_lsp_request = nil
				end
				message = message .. ". Request: ["
				for k, v in pairs(request) do
					message = message .. "{" .. k .. ", " .. v .. "}, "
				end
				message = message .. "]"
			end
			vim.notify(message)
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
			vim.notify(
				"Saving cursor: " .. cursor_pos[1] .. " " .. cursor_pos[2] .. " for buffer: " .. buffer_name .. " BufferId: " .. vim.api.nvim_get_current_buf()
			)
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
			if current_lsp_request ~= nil then
				vim.notify("Entering buf with current request: " .. current_lsp_request)
			else
				vim.notify("ENTERING BUF WITH NIL REQUEST")
			end
			vim.fn.setcursorcharpos(cursor_pos[1], cursor_pos[2], 0)
		end,
	})
end

M.restore_position = function()
	local buffer_name = getBufferName(vim.api.nvim_get_current_buf())
	if buffer_name == nil then
		return
	end

	local cursor_pos = buffer_cursor_memory[buffer_name]
	if cursor_pos == nil then
		return
	end
	vim.schedule(function()
		vim.notify("Restoring cursor position: " .. cursor_pos[1] .. " " .. cursor_pos[2] .. " for buffer: " .. buffer_name)
		vim.fn.setcursorcharpos(cursor_pos[1], cursor_pos[2], 0)
	end)
end

return M

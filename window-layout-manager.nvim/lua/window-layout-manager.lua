local util = require("util")

local M = {}

local open_windows = {}
local floating_windows = {}

---@param buf number the buffer number
local function delete_open_window(buf)
	local index_to_be_removed = -1
	for i, v in pairs(open_windows) do
		if v[1] == buf then
			index_to_be_removed = i
			goto continue
		end
	end

	::continue::
	if index_to_be_removed ~= -1 then
		table.remove(open_windows, index_to_be_removed)
	end
end

M.setup = function()
	vim.api.nvim_create_autocmd("WinNew", {
		callback = function(args)
			local current_window = vim.api.nvim_get_current_win()

			local current_window_config = vim.api.nvim_win_get_config(current_window)
			local window_buffer = vim.api.nvim_win_get_buf(current_window)
			local buffer_name = vim.api.nvim_buf_get_name(window_buffer)
			vim.notify(
				"WinNew: "
					.. util.table_to_string(current_window_config)
					.. "\n"
					.. util.table_to_string(args)
					.. " currentWindow: "
					.. current_window
					.. " buffer_name: "
					.. buffer_name
			)
			table.insert(open_windows, { args["buf"], args["file"], args["id"] })
			-- local fileType = type(args["file"])
			-- print(fileType)
		end,
	})

	vim.api.nvim_create_autocmd("WinEnter", {
		callback = function(args)
			local current_window = vim.api.nvim_get_current_win()
			local current_window_config = vim.api.nvim_win_get_config(current_window)
			local window_buffer = vim.api.nvim_win_get_buf(current_window)
			local buffer_name = vim.api.nvim_buf_get_name(window_buffer)
			if current_window_config["relative"] == nil or current_window_config["relative"] == "" then
				if buffer_name ~= nil and buffer_name ~= "" then
					vim.notify(
						"WinEnter: "
							.. util.table_to_string(current_window_config)
							.. "\n"
							.. util.table_to_string(args)
							.. " current window: "
							.. current_window
							.. " current buffername: "
							.. buffer_name
					)
					open_windows[current_window] = { args["buf"], args["file"], args["id"] }
					-- table.insert(open_windows, { args["buf"], args["file"], args["id"] })
				end
			else
				table.insert(floating_windows, window_buffer)
			end
			-- local fileType = type(args["file"])
			-- print(fileType)
		end,
	})

	vim.api.nvim_create_autocmd("WinResized", {
		callback = function(args)
			local current_window = vim.api.nvim_get_current_win()
			local window_buffer = vim.api.nvim_win_get_buf(current_window)
			local buffer_name = vim.api.nvim_buf_get_name(window_buffer)
			local current_window_config = vim.api.nvim_win_get_config(current_window)

			if buffer_name ~= nil and buffer_name ~= "" then
				vim.notify(
					"WinResized: "
						.. util.table_to_string(current_window_config)
						.. "\n"
						.. util.table_to_string(args)
						.. " current window: "
						.. current_window
						.. " current buffername: "
						.. buffer_name
				)
			end
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			if open_windows[args["buf"]] ~= nil then
				vim.notify("WinClosed: " .. util.table_to_string(args))
				delete_open_window(args["buf"])
				-- util.delete_from_table(open_windows, args["buf"])
				vim.notify("Opened windows: " .. util.table_to_string(open_windows))
			elseif floating_windows[args["buf"]] ~= nil then
				vim.notify("floating window was closed: " .. util.table_to_string(args))
			end
			-- local isInternalWindow = tonumber(args["file"])
			-- print(isInternalWindow)
			-- -- if isInternalWindow == false then
			-- print(util.table_to_string(args))
			-- end
		end,
	})
end

return M

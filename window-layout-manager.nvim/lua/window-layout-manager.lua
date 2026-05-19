local util = require("util")

local M = {
	-- open_windows = {},
}

-- M.open_windows = {}
local floating_windows = {}

---@param buf number the buffer number
local function delete_open_window(buf)
	local index_to_be_removed = -1
	for i, v in pairs(M.open_windows) do
		if v[1] == buf then
			index_to_be_removed = i
			goto continue
		end
	end

	::continue::
	if index_to_be_removed ~= -1 then
		table.remove(M.open_windows, index_to_be_removed)
	end
end

M.setup = function()
	M.open_windows = {}

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
			M.open_windows[current_window] = { args["width"], args["height"] }
			-- table.insert(open_windows, { args["buf"], args["file"], args["id"] })
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
				if buffer_name ~= nil and buffer_name ~= "" and M.open_windows[current_window] == nil then
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
					-- open_windows[current_window] = { args["buf"], args["file"], args["id"], args["width"], args["height"] }
					M.open_windows[current_window] = { args["width"], args["height"] }

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
			-- M.open_windows[current_window] = { args["width"], args["height"] }
			M.open_windows[current_window] = { args["width"], args["height"] }
			-- vim.notify("Changing window: " .. #open_windows)
			if buffer_name ~= nil and buffer_name ~= "" then
				-- M.open_windows[current_window] = "hoi"
				-- table.insert(open_windows, current_window, { args["width"], args["height"] })
				vim.notify("SIZE: " .. util.table_to_string(M.open_windows))
				-- vim.notify(
				-- 	"WinResized: "
				-- 		.. util.table_to_string(current_window_config)
				-- 		.. "\n"
				-- 		.. util.table_to_string(args)
				-- 		.. " current window: "
				-- 		.. current_window
				-- 		.. " current buffername: "
				-- 		.. buffer_name
				-- )
			end
		end,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		callback = function(args)
			if M.open_windows[args["buf"]] ~= nil then
				vim.notify("WinClosed: " .. util.table_to_string(args))
				delete_open_window(args["buf"])
				-- util.delete_from_table(open_windows, args["buf"])
				vim.notify("Opened windows: " .. util.table_to_string(M.open_windows))
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

M.printState = function()
	local msg = "States: " .. #M.open_windows .. "\n"
	for k, v in pairs(M.open_windows) do
		msg = msg .. k .. ": " .. util.table_to_string(M.open_windows[k]) .. "\n"
	end
	vim.notify(msg)
	-- print(msg)
end

return M

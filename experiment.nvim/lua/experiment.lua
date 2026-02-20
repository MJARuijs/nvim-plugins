-- print("Loaded Experiment.lua")
vim.notify("Loaded Experiment.lua")

local M = {}

local buffer_history = {}
local buffers = {}
local windows = {}
local current_buffer = nil
Start = false
Stop = false

local function sleep(n)
	os.execute("sleep " .. tonumber(n))
end

local function deleteFromTable(table, entry)
	table[entry] = nil
end

local function goDefinitionTest()
	local definition = vim.lsp.buf.definition()
	if definition and #definition > 0 then
		vim.notify("Definition found at:", definition[1].targetUri)
	end
end

local function getBufferName(buffer_id)
	local buffer_name = vim.api.nvim_buf_get_name(buffer_id)
	local endIndex = string.find(buffer_name, "/[^/]*$")
	if endIndex == nil then
		return nil
	end
	return string.sub(buffer_name, endIndex + 1)
end

local function debugPrint()
	print("--- START OF DEBUG PRINT ---")
	for key, value in pairs(buffers) do
		if vim.api.nvim_buf_is_valid(key) then
			local buffer_name = getBufferName(key)
			if buffer_name ~= nil then
				print("BufferId: " .. key .. ". Name: " .. buffer_name .. ". WindowId: " .. value)
			end
		end
	end
	print("--- END OF DEBUG PRINT ---")
end

local function printCursorPos()
	local line_number = vim.fn.getpos(".")[2]
	local column = vim.fn.getpos(".")[3]
	print("Line: " .. line_number .. ", column: " .. column)
end
-- local bufAddTest = function()
-- 	print("Buffer added with id: " .. vim.api.nvim_get_current_buf())
-- end

local function indexOf(list, item)
	for i, v in pairs(list) do
		if v == item then
			return i
		end
	end
	return -1
end

local function updateBufferHistory(most_recent_buffer)
	local index = indexOf(buffer_history, most_recent_buffer)
	if index == -1 then
		table.insert(buffer_history, 1, most_recent_buffer)
	else
		table.remove(buffer_history, index)
		table.insert(buffer_history, 1, most_recent_buffer)
	end

	print("--- Start of Buffer History ---")
	for k, v in pairs(buffer_history) do
		local buffer_name = getBufferName(v)
		print("Entry in buffer history: " .. v .. "|" .. buffer_name .. " at " .. k)
	end
	print("--- End of Buffer History ---")
end

local function deleteBufferFromHistory(buffer_id)
	local index = indexOf(buffer_history, buffer_id)
	if index == -1 then
		return
	end
	table.remove(buffer_history, index)
end

local function getRecentBuffersForWindow()
	local all_buffers = vim.api.nvim_list_bufs()
	local open_buffers = {}
	for k, v in pairs(buffers) do
		if k ~= nil and vim.api.nvim_buf_is_loaded(k) then
			if vim.api.nvim_buf_is_valid(k) then
				local buffer_name = getBufferName(k)
				if buffer_name ~= nil then
					-- print("BufferId: " .. v .. ". Name: " .. buffer_name)
					table.insert(open_buffers, k .. "|" .. buffer_name)
				end
			end

			-- open_buffers:insert(v)
		end
	end
	return open_buffers
end

local function bufEnterCallback(buffer_id, window_id)
	current_buffer = buffer_id
	local buffer_name = getBufferName(buffer_id)
	if buffer_name == nil or buffer_name == "" then
		return
	end

	updateBufferHistory(buffer_id)
	-- print("Entering buffer: " .. vim.api.nvim_get_current_buf() .. " in window " .. vim.api.nvim_get_current_win())
	local currentBufferWindow = buffers[buffer_id]

	if currentBufferWindow == nil then
		print("Switched to buffer with name: " .. buffer_name .. " at new window: " .. window_id)
	else
		-- print("Switched to buffer with name: " .. buffer_name .. " known at window: " .. currentBufferWindow .. ". Now at window: " .. window_id)
	end
	if currentBufferWindow ~= nil and currentBufferWindow ~= window_id then
		if Start then
			print(
				"PROBLEM: Buffer "
					.. buffer_id
					.. ", "
					.. buffer_name
					.. " was previously openend in Window "
					.. currentBufferWindow
					.. ", but tried to open in window "
					.. window_id
			)
			vim.schedule(function()
				local line_number = vim.fn.getpos(".")[2]
				local column = vim.fn.getpos(".")[3]
				print("Line: " .. line_number .. ", column: " .. column)

				vim.cmd([[e #]])
				vim.api.nvim_win_set_buf(currentBufferWindow, buffer_id)

				vim.schedule(function()
					vim.api.nvim_set_current_win(currentBufferWindow)
					vim.api.nvim_win_set_cursor(currentBufferWindow, { line_number, column - 1 })
				end)
			end)
		end
	elseif currentBufferWindow == nil then
		buffers[buffer_id] = window_id
		-- updateBufferHistory(buffer_id)
		print("Adding buffer to list: " .. buffer_id .. " " .. buffer_name)
	end
end

local function bufDeleteCallback(buffer_id)
	-- buffers[buffer_id] = nil
	local buf_to_del = current_buffer
	deleteBufferFromHistory(buf_to_del)
	local buffer_name = getBufferName(buf_to_del)
	if buffer_name == nil or buffer_name == "" then
		return
	end

	-- if buffer_name ~= nil and buffer_name ~= "" then
	print("Deleting from buffers: " .. buf_to_del .. ", " .. buffer_name)
	-- else
	-- 	print("Deleting from buffers: " .. buf_to_del)
	-- end

	deleteFromTable(buffers, buf_to_del)

	local current_window = vim.api.nvim_get_current_win()

	for i, v in pairs(buffer_history) do
		local window_containing_buffer = buffers[v]
		if window_containing_buffer ~= nil and window_containing_buffer == current_window then
			vim.schedule(function()
				vim.api.nvim_win_set_buf(current_window, v)
				print("FALLING BACK TO PREVIOUS BUFFER: " .. v .. " IN WINDOW: " .. current_window)
			end)
			return
		end
	end

	print("NO FALLBACK BUFFER WAS FOUND FOR WINDOW " .. current_window)
end

local function delete_buffer(buffer_id)
	bufDeleteCallback(buffer_id)

	local current_window = vim.api.nvim_get_current_win()

	for i, v in pairs(buffer_history) do
		local window_containing_buffer = buffers[v]
		if window_containing_buffer ~= nil and window_containing_buffer == current_window then
			vim.schedule(function()
				vim.api.nvim_win_set_buf(current_window, v)
				print("FALLING BACK TO PREVIOUS BUFFER: " .. v .. " IN WINDOW: " .. current_window)
			end)
			return
		end
	end

	print("NO FALLBACK BUFFER WAS FOUND FOR WINDOW " .. current_window)
	-- local open_buffers = getRecentBuffersForWindow()
	-- print(open_buffers)
	-- vim.api.nvim_buf_delete(buffer_id, {})
	-- vim.cmd("bprevious")
	-- vim.cmd("bdelete" .. buffer_id)
end

M.setup = function()
	print("Loaded Experiment.lua")

	-- vim.api.nvim_create_autocmd("BufAdd", {
	-- 	callback = function()
	-- 		bufAddTest()
	-- 		-- vim.lsp.buf.definition()
	-- 		-- vim.notify("Buffer Added to window: " .. vim.api.nvim_get_current_win() .. " LOL")
	-- 	end,
	-- })
	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function()
			if Stop == false then
				print("BUFENTER ON BUFFER " .. vim.api.nvim_get_current_buf() .. " IN WINDOW " .. vim.api.nvim_get_current_win())
				vim.schedule(function()
					bufEnterCallback(vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win())
				end)
			end
		end,
	})
	-- vim.api.nvim_create_autocmd("BufUnload", {
	-- 	callback = function()
	-- 		bufDeleteCallback(vim.api.nvim_get_current_buf())
	-- 	end,
	-- })
	vim.api.nvim_create_autocmd("BufDelete", {
		callback = function()
			print("DELETE BUF AUTOCMD")
			bufDeleteCallback(vim.api.nvim_get_current_buf())
		end,
	})

	-- vim.api.nvim_create_autocmd("BufWinLeave", {
	-- 	callback = function()
	-- 		print("BUF WIN LEAVE")
	-- 	end,
	-- })

	vim.api.nvim_create_autocmd("WinEnter", {
		callback = function()
			-- print("Entering window: " .. vim.api.nvim_get_current_win() .. " containing buffer: " .. vim.api.nvim_get_current_buf())
		end,
	})
	-- KEYS
	vim.keymap.set("n", "<leader>zd", function()
		delete_buffer(vim.api.nvim_get_current_buf())
	end, { desc = "Delete buffer" })
	vim.keymap.set("n", "<leader>zt", goDefinitionTest, { desc = "test" })

	vim.keymap.set("n", "<leader>zs", function()
		if Start then
			Start = false
		else
			Start = true
		end
		vim.notify("Started experiment")
	end, { desc = "Start" })

	vim.keymap.set("n", "<leader>zS", function()
		if Stop then
			Stop = false
		else
			Stop = true
		end
	end, { desc = "Stop" })

	vim.keymap.set("n", "<leader>zp", debugPrint, { desc = "Debug Print" })
	vim.keymap.set("n", "<leader>zP", printCursorPos, { desc = "Print CursorPos" })
	vim.keymap.set("n", "<leader>zb", function()
		print(current_buffer .. " on window " .. vim.api.nvim_get_current_win())
	end, { desc = "Print current buffer & window" })

	vim.keymap.set("n", "<leader>zB", function()
		local open_buffers = getRecentBuffersForWindow()
		print("--- START OF OPEN BUFFERS ---")
		for _, v in pairs(open_buffers) do
			print(v)
		end

		print("--- END OF OPEN BUFFERS ---")
	end, { desc = "Print open buffers" })
end

return M

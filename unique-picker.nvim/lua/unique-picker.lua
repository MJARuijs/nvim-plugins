local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local colors = function(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "colors",
			finder = finders.new_table({
				results = { "red", "green", "blue" },
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

M.setup = function()
	vim.keymap.set("n", "<leader>zr", function()
		colors()
	end, { desc = "COLORS" })
end
-- to execute the function
-- colors()
return M

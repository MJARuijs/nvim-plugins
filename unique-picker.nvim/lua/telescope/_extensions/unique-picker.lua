-- local config = {}
--
-- local function filterDuplicates(array)
-- 	print("DOEI")
-- 	local uniqueArray = {}
-- 	for _, tableA in ipairs(array) do
-- 		local isDuplicate = false
-- 		for _, tableB in ipairs(uniqueArray) do
-- 			if vim.deep_equal(tableA, tableB) then
-- 				isDuplicate = true
-- 				break
-- 			end
-- 		end
-- 		if not isDuplicate then
-- 			table.insert(uniqueArray, tableA)
-- 		end
-- 	end
-- 	return uniqueArray
-- end
--
-- local function on_list(options)
-- 	-- options.items = filterDuplicates(options.items)
-- 	print("HOI")
-- 	vim.fn.setqflist({}, " ", options)
-- 	vim.cmd.cfirst()
-- 	vim.cmd("botright copen")
-- end
--
-- local stuff = function(opts)
-- 	print("HOIIIII")
-- 	-- return {
-- 	--
-- 	-- 	"lol",
-- 	-- 	"no",
-- 	-- }
-- 	-- filterDuplicates(require("telescope.builtin").lsp_references())
-- 	vim.lsp.buf.references(nil, { on_list = on_list })
-- end
--
-- return require("telescope").register_extension({
-- 	-- setup = function(ext_config)
-- 	-- 	config = ext_config or {}
-- 	-- end,
-- 	exports = {
-- 		stuff = stuff,
-- 	},
-- })
-- our picker function: colors
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

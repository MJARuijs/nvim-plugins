local M = {}

M.delete_from_table = function(t, entry)
	local index_to_be_removed = -1
	for i, v in pairs(t) do
		if v == entry then
			index_to_be_removed = i
			goto continue
		end
	end
	goto continue
	::continue::

	if index_to_be_removed ~= -1 then
		table.remove(t, index_to_be_removed)
	end
end

function string.startsWith(s, substring)
	return s:gsub(s, 1, string.len(substring)) == substring
end

function string.ends(s, substring)
	return string.sub(s, -#substring)
end

function string.endsWith(s, substring)
	return string.sub(s, -#substring) == substring
end

function string.trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function padTabs(amount)
	local tabs = ""
	for i = 1, amount do
		tabs = tabs .. "\t"
	end
	return tabs
end

M.table_to_string = function(t, level)
	level = level or 0
	local result = ""
	for k, v in pairs(t) do
		result = result .. padTabs(level)
		if type(v) == "table" then
			local subresult = M.table_to_string(v, level + 1)
			if #subresult == 0 then
				result = result .. "{" .. k .. ":" .. "{}" .. "}\n"
			else
				result = result .. "{" .. k .. ":\n" .. subresult .. "" .. padTabs(level) .. "}\n"
			end
		else
			if type(v) == "string" or type(v) == "number" then
				result = result .. k .. ': "' .. v .. '"\n'
			elseif type(v) == "boolean" then
				if v == true then
					result = result .. k .. ": true\n"
				else
					result = result .. k .. ": false\n"
				end
			else
				result = result .. k .. ": " .. type(v) .. "\n"
			end
		end
		-- result = result .. k .. " " ..
		-- if type(v) == "string" then
		--     result = result .. v
		-- end
		-- for k2, v2 in pairs(v) do
		-- 	if type(v2) == "string" then
		-- 		result = result .. "\t{" .. k2 .. " : String(" .. v2 .. ")}\n"
		-- 	else
		-- 		result = result .. "\t{" .. k2 .. " : " .. type(v2) .. "}\n"
		-- 	end
		-- end
		--
		-- result = result .. "\n]\n"
	end

	return result
end
-- M.setup = function() end

return M

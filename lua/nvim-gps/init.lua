local ts_utils = require("nvim-treesitter.ts_utils")
local ts_parsers = require("nvim-treesitter.parsers")

local M = {}

local config = {
	icons = {
		["class-name"] = ' ',
		["function-name"] = ' ',
		["method-name"] = ' '
	},
	languages = {
		["bash"] = true,       -- bash and zsh
		["c"] = true,
		["cpp"] = true,
		["elixir"] = true,
		["fennel"] = true,
		["go"] = true,
		["java"] = true,
		["jsx"] = true,
		["javascript"] = true,
		["lua"] = true,
		["python"] = true,
		["rust"] = true,
		["tsx"] = true,
		["typescript"] = true,
	},
	separator = ' > ',
}

local cache_value = ""
local gps_query = nil
local bufnr = 0
local filelang = ""
local setup_complete = false
local transform = nil

local function default_transform(capture_name, capture_text)
	if config.icons[capture_name] ~= nil then
		return config.icons[capture_name] .. capture_text
	end
end

local transform_lang = {
	["cpp"] = function(capture_name, capture_text)
		if capture_name == "multi-class-name" then
			return config.icons["class-name"]..string.gsub(capture_text, "%s*%:%:%s*", config.separator..config.icons["class-name"])
		else
			return default_transform(capture_name, capture_text)
		end
	end
}

function M.is_available()
	return setup_complete and config.languages[filelang]
end

function M.update_fileinfo()
	filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
	bufnr = vim.fn.bufnr()
	transform = transform_lang[filelang]
end

function M.update_query()
	gps_query = vim.treesitter.get_query(filelang, "nvimGPS")
end

function M.setup(user_config)
	-- By default enable all languages
	for k, _ in pairs(config.languages) do
		config.languages[k] = ts_parsers.has_parser(k)
		if transform_lang[k] == nil then
			transform_lang[k] = default_transform
		end
	end

	transform = default_transform

	-- Override default with user settings
	if user_config then
		if user_config.icons then
			for k, v in pairs(user_config.icons) do
				config.icons[k] = v
			end
		end
		if user_config.languages then
			for k, v in pairs(user_config.languages) do
				if config.languages[k] then
					config.languages[k] = v
				end
			end
		end
		if user_config.separator ~= nil then
			config.separator = user_config.separator
		end
	end

	-- Autocommands to query
	vim.cmd[[
		augroup nvimGPS
		autocmd!
		autocmd BufEnter * silent! lua require("nvim-gps").update_fileinfo()
		autocmd BufEnter * silent! lua require("nvim-gps").update_query()
		autocmd InsertLeave * silent! lua require("nvim-gps").update_query()
		augroup END
	]]

	require("nvim-treesitter.configs").setup({
		nvimGPS = {
			enable = true
		}
	})

	setup_complete = true
end

function M.get_location()
	-- Inserting text cause error nodes
	if vim.fn.mode() == 'i' then
		return cache_value
	end

	if not gps_query then
		M.update_query()
		if not gps_query then
			return "error"
		end
	end

	local current_node = ts_utils.get_node_at_cursor()

	local node_text = {}
	local node = current_node

	while node do
		local iter = gps_query:iter_captures(node, bufnr)
		local capture_ID, capture_node = iter()

		if capture_node == node then
			if gps_query.captures[capture_ID] == "scope-root" then

				capture_ID, capture_node = iter()
				local capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 1, transform(capture_name, ts_utils.get_node_text(capture_node)[1]))

			elseif gps_query.captures[capture_ID] == "scope-root-2" then

				capture_ID, capture_node = iter()
				local capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 1, transform(capture_name, ts_utils.get_node_text(capture_node)[1]))

				capture_ID, capture_node = iter()
				capture_name = gps_query.captures[capture_ID]
				table.insert(node_text, 2, transform(capture_name, ts_utils.get_node_text(capture_node)[1]))

			end
		end

		node = node:parent()
	end

	cache_value = table.concat(node_text, config.separator)
	return cache_value
end

return M

local vim = vim
local log = require("vimwars.log")

local element = {}

-- TODO: Center by longest line and support table param
function element.center(state, line)
	local win_width = state.win_width
	local line_width = vim.fn.strdisplaywidth(line)
	local spaces = math.min((win_width - line_width) / 2)
	return string.rep(" ", spaces) .. line
end

function element.margin(text, top, bottom)
	if top then
		for i = 1, top do
			table.insert(text, 0 + i, "")
		end
	end
	if bottom then
		for _ = 1, bottom do
			table.insert(text, "")
		end
	end
	return text
end

function element.highlight(el, end_ln, state)
	local highlights = {}
	for i = state.line, end_ln do
		local hl = { state.buf, -1, el.opts.highlight, i, 0, -1 }
		table.insert(highlights, hl)
	end
	return highlights
end

function element.text(el, state)
	local lines = {}
	local highlights = {}
	local end_ln = state.line

	if type(el.text) == "table" then
		if el.opts.position == "center" then
			for _, ln in pairs(el.text) do
				table.insert(lines, element.center(state, ln))
			end
		else
			for _, ln in pairs(el.text) do
				table.insert(lines, ln)
			end
		end
		end_ln = state.line + #el.text
	end

	if type(el.text) == "string" then
		if el.opts.position == "center" then
			table.insert(lines, element.center(state, el.text))
		else
			table.insert(lines, el.text)
		end
		end_ln = state.line + 1
	end

	if el.opts.margin_top then
		lines = element.margin(lines, el.opts.margin_top)
		end_ln = end_ln + el.opts.margin_top
	end

	if el.opts.margin_bottom then
		lines = element.margin(lines, 0, el.opts.margin_bottom)
		end_ln = end_ln + el.opts.margin_bottom
	end

	if el.opts and el.opts.highlight then
		highlights = element.highlight(el, end_ln, state)
	end

	state.line = end_ln
	return lines, highlights
end

function element.button(el, state)
	-- TODO: Add buffer keybinds
	local lines, highlights = element.text(el, state)
	return lines, highlights
end

local function layout(elements, state)
	local text = {}
	local highlights = {}
	for _, el in pairs(elements) do
		local el_text, el_highlight = element[el.type](el, state)
		vim.list_extend(text, el_text)
		vim.list_extend(highlights, el_highlight)
	end
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, text)
	for _, hl in pairs(highlights) do
		vim.api.nvim_buf_add_highlight(hl[1], hl[2], hl[3], hl[4], hl[5], hl[6])
	end
end

local M = {}

-- @param win target window
-- @param buf target buffer
-- @param elements table of elements to create (text|button)
function M.cfg(win, buf, elements)
	return {
		win = win,
		buf = buf,
		elements = elements,
	}
end

-- @param text string or table value of text to be printed
-- @param opts.position horizontal position ("left"|"center")
-- @param opts.highlight the highlight group to be assigned to the element
-- @param opts.margin_top number of whitespace lines to be added above element
-- @param opts.margin_bottom number of whitespace lines to be added below element
function M.text(text, opts)
	return {
		type = "text",
		text = text,
		opts = {
			position = opts.position or "left",
			highlight = opts.highlight or "Normal",
			margin_top = opts.margin_top or nil,
			margin_bottom = opts.margin_bottom or nil,
		},
	}
end

-- @param text string or table value of text to be printed
-- @param command the vim command which would trigger the function on press
-- @param opts.keybind the keybind which would trigger the function
-- @param opts.position horizontal position ("left"|"center")
-- @param opts.highlight the highlight group to be assigned to the element
-- @param opts.margin_top number of whitespace lines to be added above element
-- @param opts.margin_bottom number of whitespace lines to be added below element
function M.button(text, command, opts)
	return {
		type = "button",
		text = text,
		command = command,
		opts = {
			keybind = opts.keybind or nil,
			position = opts.position or "left",
			highlight = opts.highlight or "Normal",
			margin_top = opts.margin_top or nil,
			margin_bottom = opts.margin_bottom or nil,
		},
	}
end

-- @param win window target
-- @param buf buffer target
-- @param cfg layout config
function M.draw(cfg)
	log.info("vimwars.layout_draw")
	vim.api.nvim_win_set_buf(cfg.win, cfg.buf)
	vim.cmd(
		[[ silent! setlocal bufhidden=wipe buftype=nofile colorcolumn= filetype= foldcolumn=0 laststatus=0 matchpairs= nobuflisted nocursorcolumn nocursorline nolist nonumber norelativenumber noruler noshowcmd noshowmode nospell noswapfile nowrapsigncolumn=no synmaxcol& ]]
	)
	local state = {
		buf = cfg.buf,
		line = 0,
		win = cfg.win,
		win_width = vim.api.nvim_win_get_width(cfg.win),
	}
	vim.api.nvim_buf_set_option(cfg.buf, "modifiable", true)
	layout(cfg.elements, state)
	vim.api.nvim_buf_set_option(cfg.buf, "modifiable", false)
	-- TODO: Redraw on resize
end

return M

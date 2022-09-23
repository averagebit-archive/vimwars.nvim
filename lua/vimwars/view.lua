local vim = vim
local log = require("vimwars.log")

local state = {}

local view = {}

function view.highlight(highlight, end_ln)
    local highlights = {}
    for i = state.line, end_ln do
        local hl = { state.buf, -1, highlight, i, 0, -1 }
        table.insert(highlights, hl)
    end
    return highlights
end

function view.center(line)
    local win_width = vim.api.nvim_win_get_width(state.win)
    local line_width = vim.fn.strdisplaywidth(line)
    local spaces = math.min((win_width - line_width) / 2)
    return string.rep(" ", spaces) .. line
end

function view.margin(text, top, bottom)
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

local element = {}

function element.text(el)
    local lines, highlights = {}, {}
    local end_ln = state.line

    if type(el.text) == "table" then
        if el.opts.position == "center" then
            for _, ln in pairs(el.text) do
                table.insert(lines, view.center(ln))
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
            table.insert(lines, view.center(el.text))
        else
            table.insert(lines, el.text)
        end
        end_ln = state.line + 1
    end

    if el.opts.margin_top then
        lines = view.margin(lines, el.opts.margin_top)
        end_ln = end_ln + el.opts.margin_top
    end

    if el.opts.margin_bottom then
        lines = view.margin(lines, 0, el.opts.margin_bottom)
        end_ln = end_ln + el.opts.margin_bottom
    end

    if el.opts.highlight then
        highlights = view.highlight(el.opts.highlight, end_ln)
    end

    state.line = end_ln
    return lines, highlights
end

function element.button(el)
    -- TODO: Add buffer keybinds
    local lines, highlights = element.text(el)
    local col = #view.center(el.text) - vim.fn.strdisplaywidth(el.text)
    local row = state.line

    if el.opts.margin_bottom then
        row = state.line - el.opts.margin_bottom
    end

    table.insert(state.cursor_jumps, { row, col })
    return lines, highlights
end

local M = {}

function M.cursor_prev()
    local prev_cursor_pos = state.cursor_pos - 1
    if prev_cursor_pos == 0 then
        return
    end
    vim.api.nvim_win_set_cursor(state.win, state.cursor_jumps[prev_cursor_pos])
    state.cursor_pos = prev_cursor_pos
end

function M.cursor_next()
    local next_cursor_pos = state.cursor_pos + 1
    if next_cursor_pos > #state.cursor_jumps then
        return
    end
    vim.api.nvim_win_set_cursor(state.win, state.cursor_jumps[next_cursor_pos])
    state.cursor_pos = next_cursor_pos
end

function M.new(cfg)
    log.info("vimwars.view.new()")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)

    function M.draw()
        log.info("vimwars.view.draw()")
        state = {
            line = 0,
            buf = buf,
            win = win,
            win_width = vim.api.nvim_win_get_width(win),
            cursor_jumps = {},
        }

        if cfg.vim_opts then
            for k, v in pairs(cfg.vim_opts) do
                vim.opt_local[k] = v
            end
        end

        if cfg.width then
            vim.api.nvim_win_set_width(state.win, cfg.width)
            state.win_width = vim.api.nvim_win_get_width(state.win)
        end

        vim.api.nvim_win_set_buf(state.win, state.buf)
        vim.api.nvim_buf_set_option(state.buf, "modifiable", true)

        local text, highlights = {}, {}
        for _, el in pairs(cfg.elements) do
            local el_text, el_highlight = element[el.type](el)
            vim.list_extend(text, el_text)
            vim.list_extend(highlights, el_highlight)
        end

        vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, text)
        for _, hl in pairs(highlights) do
            vim.api.nvim_buf_add_highlight(hl[1], hl[2], hl[3], hl[4], hl[5], hl[6])
        end

        vim.api.nvim_buf_set_option(state.buf, "modifiable", false)

        if cfg.cursor_constrain and #state.cursor_jumps > 0 then
            state.cursor_pos = 1
            vim.api.nvim_win_set_cursor(state.win, state.cursor_jumps[1])
            vim.api.nvim_buf_set_keymap(
                state.buf,
                "n",
                "k",
                "<cmd>lua require('vimwars.view').cursor_prev()<CR>",
                { noremap = false, silent = true }
            )

            vim.api.nvim_buf_set_keymap(
                state.buf,
                "n",
                "j",
                "<cmd>lua require('vimwars.view').cursor_next()<CR>",
                { noremap = false, silent = true }
            )
        end
    end

    -- https://vimhelp.org/autocmd.txt.html#%7Bevent%7D
    local augroup = vim.api.nvim_create_augroup("VimwarsView", { clear = true })
    if cfg.resize then
        vim.api.nvim_create_autocmd({ "VimResized" }, {
            group = augroup,
            callback = function()
                M.draw()
            end,
        })
    end

    M.draw()

    return state
end

return M

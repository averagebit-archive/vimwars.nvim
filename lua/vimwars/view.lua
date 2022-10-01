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

    if el.opts and el.opts.keybind then
        local k = el.opts.keybind
        vim.api.nvim_buf_set_keymap(state.buf, k.mode, k.lhs, k.rhs, k.opts)
    end

    local pos, action = { row, col }, el.callback or nil
    table.insert(state.cursor.jumps, { pos = pos, action = action })
    return lines, highlights
end

local M = {}

function M.press()
    if state.cursor.action then
        state.cursor.action()
    end
end

function M.cursor_prev()
    local i = state.cursor.index - 1
    if i < 1 then
        return
    end
    state.cursor.index = i
    state.cursor.pos = state.cursor.jumps[i].pos
    state.cursor.action = state.cursor.jumps[i].action
    vim.api.nvim_win_set_cursor(state.win, state.cursor.pos)
end

function M.cursor_next()
    local i = state.cursor.index + 1
    if i > #state.cursor.jumps then
        return
    end
    state.cursor.index = i
    state.cursor.pos = state.cursor.jumps[i].pos
    state.cursor.action = state.cursor.jumps[i].action
    vim.api.nvim_win_set_cursor(state.win, state.cursor.pos)
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
            cursor = {},
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

        if cfg.opts and cfg.opts.modifiable == false then
            vim.api.nvim_buf_set_option(state.buf, "modifiable", false)
        end

        if cfg.opts and cfg.opts.cursor_constrain and #state.cursor.jumps > 0 then
            state.cursor.index = 1
            state.cursor.pos = state.cursor.jumps[1].pos
            state.cursor.action = state.cursor.jumps[1].action

            vim.api.nvim_win_set_cursor(state.win, state.cursor.pos)

            local k = {
                buf = state.buf,
                mode = "n",
                lhs = nil,
                rhs = nil,
                opts = { noremap = true, silent = true, nowait = true },
            }

            -- TODO: use CursorMoved autocmd event to handle this
            k.lhs, k.rhs = "k", "<cmd>lua require('vimwars.view').cursor_prev()<CR>"
            vim.api.nvim_buf_set_keymap(k.buf, k.mode, k.lhs, k.rhs, k.opts)

            k.lhs, k.rhs = "j", "<cmd>lua require('vimwars.view').cursor_next()<CR>"
            vim.api.nvim_buf_set_keymap(k.buf, k.mode, k.lhs, k.rhs, k.opts)

            k.lhs, k.rhs = "<CR>", "<cmd>lua require('vimwars.view').press()<CR>"
            vim.api.nvim_buf_set_keymap(k.buf, k.mode, k.lhs, k.rhs, k.opts)
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

    vim.api.nvim_buf_set_keymap(state.buf, 'n', '<Enter>', '', {
        nowait = true, noremap = false, silent = true
    })

    return state
end

return M

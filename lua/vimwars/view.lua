local vim = vim

local state = {
    line = 0,
    buf = nil,
    win = nil,
    win_width = 0,
}

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
    local line_width = vim.fn.strdisplaywidth(line)
    local spaces = math.min((state.win_width - line_width) / 2)
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
    -- TODO: Save cursor jump points in state
    local lines, highlights = element.text(el)
    return lines, highlights
end

local M = {}

-- @param cfg
function M.new(cfg)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)

    local function draw()
        state = {
            line = 0,
            buf = buf,
            win = win,
            win_width = vim.api.nvim_win_get_width(win),
        }

        vim.api.nvim_win_set_buf(state.win, state.buf)
        vim.api.nvim_buf_set_option(state.buf, "modifiable", true)

        vim.cmd([[ setlocal nonumber norelativenumber ]])

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
    end

    draw()

    local augroup_name
    if cfg.name then
        augroup_name = "VimwarsView" .. cfg.name
    else
        augroup_name = "VimwarsView" .. os.time()
    end

    local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })
    vim.api.nvim_create_autocmd({ "VimResized" }, {
        group = augroup,
        callback = function()
            draw()
        end,
    })

    return state
end

return M

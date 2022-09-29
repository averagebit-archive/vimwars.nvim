local api = vim.api

local function createMenu()
    local cur_win = api.nvim_get_current_win()
    local buf = api.nvim_create_buf(false, true)
    local win_height = api.nvim_win_get_height(cur_win)

    local someWin = api.nvim_open_win(buf, false, {
        relative = 'win',
        row = 0,
        col = 0,
        width = 15,
        height = win_height
    })

    log.info("wins")
    log.info(someWin)
    api.nvim_set_current_win(someWin)
    api.nvim_win_set_cursor(someWin, { 1, 1 })
end

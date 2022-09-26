local api = vim.api
local log = require("vimwars.log")
local dash = require("vimwars.dash")
local game = require("vimwars.game")


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

local M = {}

local function openDash(buf)
    api.nvim_buf_delete(buf, {})
    local dashState = dash.open()

    local openG = ':lua require"vimwars.init".openGame(' .. dashState.buf .. ')<cr>'
    api.nvim_buf_set_keymap(dashState.buf, 'n', 'y', openG, {
        nowait = true, noremap = false, silent = true
    })
end

local function openGame(buf)
    api.nvim_buf_delete(buf, {})
    local state = game.open()
    local openG = ':lua require"vimwars.init".openDash(' .. state.buf .. ')<cr>'

    api.nvim_buf_set_keymap(state.buf, 'n', 't', openG, {
        nowait = true, noremap = false, silent = true
    })
end

function M.init()
    log.info("--------- Vimwars Initialized ---------")
    local dashState = dash.open()
    log.info(dashState.buf)
    local openG = ':lua require"vimwars.init".openGame(' .. dashState.buf .. ')<cr>'
    api.nvim_buf_set_keymap(dashState.buf, 'n', 'y', openG, {
        nowait = true, noremap = false, silent = true
    })
    createMenu()
end


return {
    init = M.init,
    openDash = openDash,
    openGame = openGame
}

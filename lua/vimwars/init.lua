local vim = vim
local log = require("vimwars.log")
local dash = require("vimwars.dash")
local game = require("vimwars.game")

local M = {}

local function openDash(buf)
    vim.api.nvim_buf_delete(buf, {})
    local dashState = dash.open()

    local openG = ':lua require"vimwars.init".openGame(' .. dashState.buf .. ')<cr>'
    vim.api.nvim_buf_set_keymap(dashState.buf, 'n', 'y', openG, {
        nowait = true, noremap = false, silent = true
    })
end

local function openGame(buf)
    vim.api.nvim_buf_delete(buf, {})
    local state = game.open()

    local openG = ':lua require"vimwars.init".openDash(' .. state.buf .. ')<cr>'
    vim.api.nvim_buf_set_keymap(state.buf, 'n', 't', openG, {
        nowait = true, noremap = false, silent = true
    })
end

function M.init()
    log.info("--------- Vimwars Initialized ---------")
    local dashState = dash.open()
    log.info(dashState.buf)
    local openG = ':lua require"vimwars.init".openGame(' .. dashState.buf .. ')<cr>'
    vim.api.nvim_buf_set_keymap(dashState.buf, 'n', 'y', openG, {
        nowait = true, noremap = false, silent = true
    })
end

return {
    init = M.init,
    openDash = openDash,
    openGame = openGame
}

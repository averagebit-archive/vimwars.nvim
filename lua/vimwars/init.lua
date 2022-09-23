local log = require("vimwars.log")
local dash = require("vimwars.dash")
local game = require("vimwars.game")
local timer = require('timer')

local M = {}

function M.init()
    log.info("--------- Vimwars Initialized ---------")
    local dashState = dash.new()
    local gameState = game.new()
    log.info(dashState)
    log.info(gameState)
end

return M

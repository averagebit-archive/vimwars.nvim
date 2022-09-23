local log = require("vimwars.log")
local dash = require("vimwars.dash")
local game = require("vimwars.game")

local M = {}

function M.init()
    log.info("--------- Vimwars Initialized ---------")
    dash.open()
    game.open()
end

return M

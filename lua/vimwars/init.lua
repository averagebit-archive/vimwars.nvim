local log = require("vimwars.log")
local dash = require("vimwars.dash")

local M = {}

function M.init()
	log.info("--------- Vimwars Initialized ---------")
	dash.open()
end

return M

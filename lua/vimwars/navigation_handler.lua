local log = require("vimwars.log")

local M = {}

function M.init(actions)
    for k, v in pairs(actions) do
        log.info(actions)
    end
end

return M

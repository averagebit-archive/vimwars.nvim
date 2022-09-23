local view = require("vimwars.view")

local vcfg = {
    name = "Game",
    elements = {
        {
            type = "button",
            text = "Start >",
            opts = {
                position = "center",
                highlight = "Normal",
                margin_bottom = 1,
            },
        }
    },
}

local M = {}

function M.new()
    return view.new(vcfg)
end

return M

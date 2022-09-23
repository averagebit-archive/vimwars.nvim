local view = require("vimwars.view")

local vcfg = {
    name = "Dashboard",
    elements = {
        {
            type = "text",
            text = {
                [[ __    __ __   __    __   __     __   ______   ______   ______   ]],
                [[/\ \  / //\ \ /\ "-./  \ /\ \  _ \ \ /\  __ \ /\  == \ /\  ___\  ]],
                [[\ \ \/ / \ \ \\ \ \-./\ \\ \ \/ ".\ \\ \  __ \\ \  __< \ \___  \ ]],
                [[ \ \__/   \ \_\\ \_\ \ \_\\ \__/".~\_\\ \_\ \_\\ \_\ \_\\/\_____\]],
                [[  \/_/     \/_/ \/_/  \/_/ \/_/   \/_/ \/_/\/_/ \/_/ /_/ \/_____/]],
            },
            opts = {
                position = "center",
                highlight = "String",
                margin_top = 2,
                margin_bottom = 2,
            },
        },
        {
            type = "button",
            text = " Begin Wars",
            opts = {
                position = "center",
                highlight = "Normal",
                margin_bottom = 1,
            },
        },
        {
            type = "text",
            text = "github.com/vimwars",
            opts = {
                position = "center",
                highlight = "Type",
            },
        },
    },
}

local M = {}

function M.new()
    return view.new(vcfg)
end

return M

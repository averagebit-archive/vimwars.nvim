local log = require("vimwars.log")
local view = require("vimwars.view")
local war = require("vimwars.war")
local intro = require("vimwars.intro")

local cfg = {
    opts = {
        -- Redraw the view on resize (default: true)
        resize = true,
        -- Constrain the cursor to buttons (default: true)
        cursor_constrain = true,
        -- Modifiable buffer option - overrides vim_opts.modifiable (default: true)
        modifiable = false,
    },
    -- Table of elements to be drawn
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
            text = "Begin Wars",
            callback = war.open,
            opts = {
                keybind = {
                    mode = "n",
                    lhs = "w",
                    rhs = "<cmd>lua require('vimwars.game').start()<CR>",
                    opts = { noremap = true, silent = true, nowait = true },
                },
                position = "center",
                highlight = "Normal",
                margin_bottom = 1,
            },
        },
        {
            type = "button",
            text = "Introduction",
            callback = intro.open,
            opts = {
                keybind = {
                    mode = "n",
                    lhs = "i",
                    rhs = "<cmd>lua require('vimwars.intro').start()<CR>",
                    opts = { noremap = true, silent = true, nowait = true },
                },
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
    -- Vim options set via vim.opt_local
    -- https://neovim.io/doc/user/quickref.html#option-list
    vim_opts = {
        colorcolumn = "",
        cursorcolumn = false,
        cursorline = false,
        foldlevel = 100,
        list = false,
        number = false,
        relativenumber = false,
        signcolumn = "no",
        spell = false,
        wrap = false,
        bufhidden = "wipe",
        buflisted = false,
        buftype = "nofile",
        filetype = "",
        matchpairs = "",
        swapfile = false,
    },
}

local M = {}

function M.open()
    log.trace("------------- dash.open() -------------")
    view.new(cfg)
end

return M

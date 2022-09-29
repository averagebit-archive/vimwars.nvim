local api = vim.api
local log = require("vimwars.log")
local view = require("vimwars.view")
local game = require("vimwars.game")

function openGame(buf)
    log.info("this is working")
    api.nvim_buf_delete(buf, {})
    game.open()
end

local vcfg = {
    name = "Dashboard",
    -- Whether to redraw the view on resize
    resize = true,
    -- Whether to constrain the cursor to jumps between buttons
    cursor_constrain = true,
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
            text = " Begin Wars",
            opts = {
                position = "center",
                highlight = "Normal",
                margin_bottom = 1,
            },
            action = openGame
        },
        {
            type = "button",
            text = " End Wars",
            opts = {
                position = "center",
                highlight = "Normal",
                margin_bottom = 1,
            },
            action = openGame
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
    log.info("vimwars.dash.open()")
    local state = view.new(vcfg)
    return state
end

return M

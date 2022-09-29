local log = require("vimwars.log")
local view = require("vimwars.view")

local vcfg = {
    name = "Dashboard",
    -- Whether to redraw the view on resize
    resize = true,
    -- Whether to constrain the cursor to jumps between buttons
    cursor_constrain = true,
    -- Table of elements to be drawn
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
    log.info("vimwars.game.open()")
    return view.new(vcfg)
end



return M

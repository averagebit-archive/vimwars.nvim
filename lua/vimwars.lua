local vim = vim
local log = require("vimwars.log")
local dash = require("vimwars.dash")

local M = {}

function M.setup(cfg)
    log.new(cfg.log, true)
    if vim.fn.has("nvim-0.7") == 0 then
        vim.notify("[Vimwars] vimwars.nvim requires Neovim 0.7 or higher", vim.log.levels.WARN)
        log.warn("vimwars.nvim requires Neovim 0.7 or higher")
        return
    end

    vim.api.nvim_create_user_command("Vimwars", dash.open, {
        desc = "Start Vimwars.",
        force = true,
        nargs = 0,
    })
end

return M

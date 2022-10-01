local io = io
local log = require("vimwars.log")
local view = require("vimwars.view")
local wars = require("vimwars.exercise").wars

local state = {
    war = nil,
    wars = wars,
    snippets_dir = debug.getinfo(1).source:sub(2):match("(.*/)") .. "files/war",
}

local M = {}

function M.open()
    log.trace("game.open()")

    state.war = state.wars[1]

    M.open_war()
end

function M.open_war()
    -- TODO: support windows paths
    local path, body = state.snippets_dir .. "/" .. state.war.name .. "." .. state.war.lang, {}
    for line in io.lines(path) do
        table.insert(body, line)
    end

    view.new({
        elements = {
            {
                type = "text",
                text = body,
            },
        },
    })
end

return M

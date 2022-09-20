local log = require("vimwars.log")
local layout = require("vimwars.layout")

local header = layout.text({
	[[ __    __ __   __    __   __     __   ______   ______   ______   ]],
	[[/\ \  / //\ \ /\ "-./  \ /\ \  _ \ \ /\  __ \ /\  == \ /\  ___\  ]],
	[[\ \ \/ / \ \ \\ \ \-./\ \\ \ \/ ".\ \\ \  __ \\ \  __< \ \___  \ ]],
	[[ \ \__/   \ \_\\ \_\ \ \_\\ \__/".~\_\\ \_\ \_\\ \_\ \_\\/\_____\]],
	[[  \/_/     \/_/ \/_/  \/_/ \/_/   \/_/ \/_/\/_/ \/_/ /_/ \/_____/]],
}, { position = "center", highlight = "String", margin_top = 2, margin_bottom = 2 })

local elements = {
	header,
	layout.button("  Begin wars", nil, { position = "center", margin_bottom = 1 }),
	layout.text("github.com/vimwars", { position = "center", highlight = "Type" }),
}

local M = {}

function M.open()
	log.info("vimwars.dash_open")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	local cfg = layout.cfg(win, buf, elements)
	layout.draw(cfg)
end

return M

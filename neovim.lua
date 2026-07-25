local palette = {
	bg = "#000000",
	bg_dark = "#121212",
	fg = "#ffffff",
	fg_dim = "#8E8E93",
	border = "#AEB1B8",
	panel = "#2C2C2E",
	dim = "#626262",

	red = "#ff4040",
	cyan = "#00ffc4",
	blue = "#0080ff",
	magenta = "#ff00c4",
	purple = "#8000c4",
	gold = "#ffc400",
	yellow = "#ffff00",
	silver = "#C0C0C0",
	steel = "#8E8E93",
	black = "#000000",
	white = "#FFFFFF",
}

local function hi(group, opts)
	local parts = { "highlight", group }
	if opts.fg then
		table.insert(parts, "guifg=" .. opts.fg)
	end
	if opts.bg then
		table.insert(parts, "guibg=" .. opts.bg)
	end
	if opts.gui then
		table.insert(parts, "gui=" .. opts.gui)
	end
	vim.cmd(table.concat(parts, " "))
end

local function apply()
	vim.o.termguicolors = true
	vim.o.background = "dark"
	vim.g.colors_name = "nocturne"

	vim.cmd("highlight clear")

	hi("Normal", { fg = palette.fg, bg = palette.bg })
	hi("CursorLine", { bg = palette.bg_dark })
	hi("CursorLineNr", { fg = palette.fg, bg = palette.bg })
	hi("LineNr", { fg = palette.dim, bg = palette.bg })
	hi("StatusLine", { fg = palette.fg, bg = palette.bg_dark })
	hi("StatusLineNC", { fg = palette.dim, bg = palette.bg_dark })
	hi("TabLine", { fg = palette.dim, bg = palette.bg_dark })
	hi("TabLineSel", { fg = palette.bg, bg = palette.fg, gui = "bold" })
	hi("VertSplit", { fg = palette.dim, bg = palette.bg })
	hi("ColorColumn", { bg = palette.bg_dark })
	hi("Visual", { fg = palette.bg, bg = palette.yellow })

	hi("Comment", { fg = palette.yellow, gui = "italic" })
	hi("Constant", { fg = palette.fg })
	hi("String", { fg = palette.fg })
	hi("Character", { fg = palette.red })
	hi("Number", { fg = palette.cyan })
	hi("Boolean", { fg = palette.cyan })
	hi("Float", { fg = palette.cyan })
	hi("Identifier", { fg = palette.blue })
	hi("Function", { fg = palette.fg })
	hi("Statement", { fg = palette.blue })
	hi("Conditional", { fg = palette.magenta })
	hi("Repeat", { fg = palette.magenta })
	hi("Label", { fg = palette.blue })
	hi("Operator", { fg = palette.gold })
	hi("Keyword", { fg = palette.blue, gui = "bold" })
	hi("Exception", { fg = palette.magenta })
	hi("PreProc", { fg = palette.blue })
	hi("Include", { fg = palette.blue })
	hi("Define", { fg = palette.blue })
	hi("Macro", { fg = palette.purple })
	hi("Type", { fg = palette.fg })
	hi("StorageClass", { fg = palette.blue })
	hi("Structure", { fg = palette.blue })
	hi("Typedef", { fg = palette.blue })
	hi("Special", { fg = palette.cyan })
	hi("SpecialComment", { fg = palette.purple })
	hi("Todo", { fg = palette.bg, bg = palette.purple, gui = "bold" })

	hi("Search", { fg = palette.bg, bg = palette.fg_dim })
	hi("IncSearch", { fg = palette.bg, bg = palette.fg })
	hi("MatchParen", { fg = palette.fg, bg = palette.silver, gui = "bold" })

	hi("DiagnosticError", { fg = palette.fg })
	hi("DiagnosticWarn", { fg = palette.fg_dim })
	hi("DiagnosticInfo", { fg = palette.fg_dim })
	hi("DiagnosticHint", { fg = palette.silver })
	hi("DiagnosticVirtualTextError", { fg = palette.fg })
	hi("DiagnosticVirtualTextWarn", { fg = palette.fg_dim })
	hi("DiagnosticSignError", { fg = palette.fg })
	hi("DiagnosticSignWarn", { fg = palette.fg_dim })
	hi("LspReferenceText", { bg = palette.silver })
	hi("LspReferenceRead", { bg = palette.silver })
	hi("LspReferenceWrite", { bg = palette.silver })

	hi("Pmenu", { fg = palette.fg, bg = palette.panel })
	hi("PmenuSel", { fg = palette.bg, bg = palette.fg })
	hi("PmenuSbar", { bg = palette.steel })
	hi("PmenuThumb", { bg = palette.silver })

	hi("TelescopeNormal", { fg = palette.fg, bg = palette.panel })
	hi("TelescopePreviewNormal", { fg = palette.fg, bg = palette.bg_dark })
	hi("TelescopePromptNormal", { fg = palette.fg, bg = palette.panel })
	hi("TelescopePromptPrefix", { fg = palette.fg, bg = palette.panel })
	hi("TelescopePromptTitle", { fg = palette.bg, bg = palette.fg })
	hi("TelescopePreviewTitle", { fg = palette.bg, bg = palette.fg })

	hi("HopNextKey", { fg = palette.fg, bg = palette.bg })
	hi("HopNextKey1", { fg = palette.fg, bg = palette.bg })
	hi("HopNextKey2", { fg = palette.fg_dim, bg = palette.bg })
	hi("LightspeedLabel", { fg = palette.fg, bg = palette.bg })
	hi("LightspeedLabelDistant", { fg = palette.fg_dim, bg = palette.bg })

	hi("TSKeyword", { fg = palette.blue, gui = "bold" })
	hi("TSString", { fg = palette.fg })
	hi("TSVariable", { fg = palette.fg })
	hi("TSField", { fg = palette.blue })
	hi("TSFunction", { fg = palette.fg })
	hi("TSMethod", { fg = palette.fg })
	hi("TSConstant", { fg = palette.fg })
	hi("TSComment", { fg = palette.yellow, gui = "italic" })
	hi("TSConstructor", { fg = palette.cyan })
	hi("TSType", { fg = palette.fg })
	hi("TSOperator", { fg = palette.gold })
	hi("TSParameter", { fg = palette.fg })
	hi("TSVariableBuiltin", { fg = palette.cyan })
	hi("TSNote", { fg = palette.bg, bg = palette.purple, gui = "bold" })

	hi("NormalFloat", { fg = palette.fg, bg = palette.panel })
	hi("FloatBorder", { fg = palette.border, bg = palette.panel })
	hi("WhichKey", { fg = palette.fg })
	hi("WhichKeyGroup", { fg = palette.fg })

	hi("GitSignsAdd", { fg = palette.cyan })
	hi("GitSignsChange", { fg = palette.gold })
	hi("GitSignsDelete", { fg = palette.red })

	hi("DiffAdd", { fg = palette.cyan, bg = palette.bg })
	hi("DiffChange", { fg = palette.gold, bg = palette.bg })
	hi("DiffDelete", { fg = palette.red, bg = palette.bg })

	vim.g.terminal_color_0 = palette.bg
	vim.g.terminal_color_1 = palette.fg
	vim.g.terminal_color_2 = palette.fg_dim
	vim.g.terminal_color_3 = palette.fg_dim
	vim.g.terminal_color_4 = palette.border
	vim.g.terminal_color_5 = palette.fg
	vim.g.terminal_color_6 = palette.steel
	vim.g.terminal_color_7 = palette.fg
	vim.g.terminal_color_8 = palette.fg_dim
	vim.g.terminal_color_9 = palette.fg
	vim.g.terminal_color_10 = palette.fg_dim
	vim.g.terminal_color_11 = palette.fg_dim
	vim.g.terminal_color_12 = palette.border
	vim.g.terminal_color_13 = palette.fg
	vim.g.terminal_color_14 = palette.steel
	vim.g.terminal_color_15 = palette.white

	hi("@comment", { fg = palette.yellow, gui = "italic" })
	hi("@comment.documentation", { fg = palette.yellow, gui = "italic" })
	hi("@comment.todo", { fg = palette.bg, bg = palette.purple, gui = "bold" })
	hi("@comment.note", { fg = palette.bg, bg = palette.purple, gui = "bold" })
	hi("@comment.warning", { fg = palette.bg, bg = palette.yellow, gui = "bold" })
	hi("@comment.error", { fg = palette.bg, bg = palette.red, gui = "bold" })

	hi("@keyword", { fg = palette.blue, gui = "bold" })
	hi("@keyword.function", { fg = palette.blue, gui = "bold" })
	hi("@keyword.operator", { fg = palette.gold })
	hi("@keyword.return", { fg = palette.magenta, gui = "bold" })
	hi("@keyword.conditional", { fg = palette.magenta, gui = "bold" })
	hi("@keyword.repeat", { fg = palette.magenta, gui = "bold" })
	hi("@keyword.exception", { fg = palette.magenta, gui = "bold" })
	hi("@keyword.import", { fg = palette.blue, gui = "bold" })
	hi("@keyword.directive", { fg = palette.blue })

	hi("@operator", { fg = palette.gold })
	hi("@punctuation.delimiter", { fg = palette.gold })
	hi("@punctuation.bracket", { fg = palette.gold })
	hi("@punctuation.special", { fg = palette.red })

	hi("@string", { fg = palette.fg })
	hi("@string.escape", { fg = palette.red })
	hi("@string.regex", { fg = palette.red })
	hi("@string.special", { fg = palette.cyan })
	hi("@character", { fg = palette.red })
	hi("@character.special", { fg = palette.red })

	hi("@constant", { fg = palette.fg })
	hi("@constant.builtin", { fg = palette.cyan })
	hi("@constant.macro", { fg = palette.purple })
	hi("@number", { fg = palette.cyan })
	hi("@boolean", { fg = palette.fg })
	hi("@float", { fg = palette.cyan })

	hi("@function", { fg = palette.fg })
	hi("@function.builtin", { fg = palette.cyan })
	hi("@function.call", { fg = palette.fg })
	hi("@function.method", { fg = palette.fg })
	hi("@function.method.call", { fg = palette.fg })
	hi("@constructor", { fg = palette.cyan })

	hi("@variable", { fg = palette.fg })
	hi("@variable.builtin", { fg = palette.cyan })
	hi("@variable.parameter", { fg = palette.fg })
	hi("@variable.member", { fg = palette.blue })
	hi("@property", { fg = palette.blue })
	hi("@field", { fg = palette.blue })

	hi("@module", { fg = palette.blue })
	hi("@module.builtin", { fg = palette.cyan })
	hi("@label", { fg = palette.magenta })
	hi("@type", { fg = palette.fg })
	hi("@type.builtin", { fg = palette.cyan })
	hi("@type.definition", { fg = palette.blue })
	hi("@attribute", { fg = palette.purple })
	hi("@tag", { fg = palette.magenta })
	hi("@tag.attribute", { fg = palette.blue })
	hi("@tag.delimiter", { fg = palette.gold })
end

local aug = vim.api.nvim_create_augroup("Nocturne", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter" }, {
	group = aug,
	callback = function()
		vim.schedule(apply)
	end,
})
vim.api.nvim_create_autocmd({ "ColorScheme" }, {
	group = aug,
	callback = function()
		vim.schedule(apply)
	end,
})

vim.api.nvim_create_user_command("ApplyNocturne", function()
	apply()
end, {})

apply()

return {}

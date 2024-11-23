-- This file is automatically loaded by plugins.config
vim.g.mapleader = ","
vim.g.maplocalleader = " "

-- coc or lsp
vim.g.usecoc = true
vim.g.coc_config_home = '~/.config/nvim'
-- disable backup file, coc need this
vim.opt.backup = false
vim.opt.writebackup = false

-- vim.g.loaded_netrw = true
-- vim.g.loaded_netrwPlugin = true

local opt = vim.opt

opt.autowrite = true          -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
if os.getenv("TMUX") then
    -- vim.g.clipboard = {
    --     name = 'tmux',
    --     copy = {
    --         ['+'] = { 'tmux', 'load-buffer', '-' },
    --         ['*'] = { 'tmux', 'load-buffer', '-' },
    --     },
    --     paste = {
    --         ['+'] = { 'tmux', 'save-buffer', '-' },
    --         ['*'] = { 'tmux', 'save-buffer', '-' },
    --     },
    --     cache_enabled = 1,
    -- }
end
-- opt.completeopt = "menu,menuone,noselect"
-- opt.conceallevel = 3 -- Hide * markup for bold and italic
-- opt.confirm = true             -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true  -- Use spaces instead of tabs
opt.tabstop = 4       -- Number of spaces tabs count for
opt.shiftwidth = 4    -- Size of an indent
-- opt.formatoptions = "jcroqlnt" -- tcqj
-- opt.grepformat = "%f:%l:%c:%m"
-- opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
-- opt.inccommand = "nosplit" -- preview incremental substitute
-- opt.laststatus = 0
opt.list = true           -- Show some invisible characters (tabs...
-- opt.mouse = "a"            -- Enable mouse mode
opt.number = true         -- Print line number
opt.pumblend = 10         -- Popup blend
opt.pumheight = 10        -- Maximum number of entries in a popup
opt.cmdheight = 1
opt.relativenumber = true -- Relative line numbers
-- opt.scrolloff = 4          -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true  -- Round indent
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false   -- Dont show mode since we have a statusline
-- opt.sidescrolloff = 8      -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true   -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spell = true
opt.spelllang = { "en" }
opt.splitbelow = true    -- Put new windows below current
opt.splitright = true    -- Put new windows right of current
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200               -- Save swap file and trigger CursorHold
opt.wildmode = "longest:full,full" -- Command-line completion mode
-- opt.winminwidth = 5                -- Minimum window width
-- opt.wrap = false                   -- Disable line wrap

-- -- opt.foldmethod = "indent"
opt.foldcolumn = "0"
opt.foldlevel = 99
vim.foldlevelstart = 99
opt.foldenable = true



-- opt.foldmethod = "indent"
-- opt.foldmethod = "expr"
-- opt.foldexpr = "CocAction('fold')"

-- opt.splitkeep = "screen"
-- opt.shortmess:append({ C = true })

-- -- Fix markdown indentation settings
-- vim.g.markdown_recommended_style = 0


-- Load lazy plugin manager
require("conf")

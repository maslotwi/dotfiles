vim.o.number = true
vim.o.wrap = false
vim.o.tabstop = 8
vim.o.swapfile = false
vim.o.clipboard =  vim.o.clipboard .. "unnamedplus"
vim.cmd("set completeopt+=menuone,noselect,noinsert")
vim.o.winborder = "rounded"
vim.o.smartindent = true
vim.o.termguicolors = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.opt.titlestring = [[%f %h%m%r%w %{v:progname} (%{tabpagenr()} of %{tabpagenr('$')})]]


vim.g.mapleader = " "

local config_path = vim.fn.stdpath("config") .. "/local_settings.json"

local function load_local_settings(filepath)
    local file = io.open(filepath, "r")
    
    if not file then
        return {} 
    end

    local content = file:read("*a")
    file:close()

    if content == "" then 
        return {} 
    end

    local ok, parsed_json = pcall(vim.json.decode, content)
    
    if not ok then
        vim.notify("Failed to parse local_settings.json!", vim.log.levels.ERROR)
        return {}
    end

    return parsed_json
end

-- Zapisanie ustawień do zmiennej
local local_settings = load_local_settings(config_path)


vim.pack.add{
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/rebelot/kanagawa.nvim' },
    { src = 'https://github.com/echasnovski/mini.icons' },
    { src = 'https://github.com/echasnovski/mini.files' },
    { src = 'https://github.com/otavioschwanck/arrow.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
--    { src = 'https://github.com/nvim-lua/plenary.nvim' },
--    { src = 'https://github.com/hrsh7th/nvim-cmp' },
--    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
--    { src = 'https://github.com/magicmonty/sonicpi.nvim' },
}

require('mini.icons').setup()
require('mini.files').setup()
require('arrow').setup({
    show_icons = true,
    leader_key = ';'
})

--require('sonicpi').setup({
--    server_dir = local_settings.sonicpi_server, -- It will try to find the SonicPi server
--    lsp_diagnostics = false, -- enable LSP diagnostics
--    mappings = {
--        { 'n', '<leader>s', require('sonicpi.remote').stop, default_mapping_opts },
--        { 'i', '<M-s>', require('sonicpi.remote').stop, default_mapping_opts },
--        { 'n', '<leader>r', require('sonicpi.remote').run_current_buffer, default_mapping_opts },
--        { 'i', '<M-r>', require('sonicpi.remote').run_current_buffer, default_mapping_opts },
--    },
--})

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
}



local hour = os.date("*t").hour
if hour >= 18 or hour <= 8 then
    vim.cmd("colorscheme kanagawa-wave")
    DARK_THEME = true
else
    vim.cmd("colorscheme kanagawa-lotus")
    DARK_THEME = false
end

local function switch_theme()
    if(DARK_THEME) then
        vim.cmd("colorscheme kanagawa-lotus")
        DARK_THEME = false
    else
        vim.cmd("colorscheme kanagawa-wave")
        DARK_THEME = true
    end
end

vim.keymap.set('n', '<leader>f', MiniFiles.open)
vim.keymap.set('n', '<leader>q', ":quit<CR>")
vim.keymap.set('n', '<leader>w', ":write<CR>")
vim.keymap.set('n', '<leader>t', switch_theme)

-- Insert mode: Save (Ctrl+S)
-- Using <C-o> allows us to execute a single normal mode command (:write) without leaving insert mode.
vim.keymap.set('i', '<C-s>', '<C-o>:write<CR>', { silent = true, desc = "Save file" })

-- Insert mode: Select whole file (Ctrl+A)
-- This escapes to normal mode (<Esc>), goes to the top (gg), enters visual line mode (V), and goes to the bottom (G).
vim.keymap.set('i', '<C-a>', '<Esc>ggVG', { silent = true, desc = "Select whole file" })

-- Insert mode: Comment/Uncomment line (Ctrl+/)
-- This uses <C-o> to briefly enter normal mode and trigger Neovim's native 'gcc' comment toggle.
vim.keymap.set('i', '<C-/>', '<C-o>gcc', { remap = true, silent = true, desc = "Toggle comment" })
vim.keymap.set('i', '<C-_>', '<C-o>gcc', { remap = true, silent = true, desc = "Toggle comment (terminal fallback)" })

-- Visual mode: Comment/Uncomment selection (Ctrl+/)
-- This triggers Neovim's native 'gc' comment operator on the current visual selection.
vim.keymap.set('v', '<C-/>', 'gc', { remap = true, silent = true, desc = "Toggle comment selection" })
vim.keymap.set('v', '<C-_>', 'gc', { remap = true, silent = true, desc = "Toggle comment selection (terminal fallback)" })



require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the listed parsers MUST always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go", "templ", "zig" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    -- List of parsers to ignore installing (or "all")
    ignore_install = { "javascript" },

    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- list of language that will be disabled
        -- disable = { "c", "rust" },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
}

-- https://www.dogeystamp.com/typst-notes2/
local function typst_watch()
    vim.cmd('vsp')
    vim.cmd('vertical resize 20')

    local current_file = vim.fn.expand("%")

    vim.cmd('terminal typst watch ' .. current_file)

    vim.cmd('wincmd h')
end

vim.keymap.set('n', '<leader>tw', typst_watch, { silent = true, desc = "Typst watch in terminal split" })

vim.keymap.set('n', '<leader>tp', function()
    local pdf_file = vim.fn.expand("%:p:r") .. ".pdf"
    vim.cmd('silent !zathura --fork ' .. vim.fn.shellescape(pdf_file) .. ' &')
end, { silent = true, desc = "Open Typst PDF in Zathura" })



vim.lsp.enable({
    'lua_ls',
    'gopls',
    'pyright',
    'clangd',
    'ts_ls',
    'templ',
    'zls',
    'glsl_analyzer',
    'tinymist'
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        vim.cmd('source ~/.config/nvim/autocomplete.vim')

        vim.diagnostic.config({ virtual_lines = true })
        vim.diagnostic.config({ virtual_text = true })
    end
})





--vim.api.nvim_create_autocmd('LspAttach', {
--callback = function(ev)
--  local client = vim.lsp.get_client_by_id(ev.data.client_id)
--  if client:supports_method('textDocument/completion') then
--	vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
--  end
--end,
--})

--vim.cmd("set completeopt+=noselect")


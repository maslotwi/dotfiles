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

vim.g.mapleader = " "

vim.pack.add{
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/rebelot/kanagawa.nvim' },
    { src = 'https://github.com/echasnovski/mini.icons' },
    { src = 'https://github.com/echasnovski/mini.files' },
    { src = 'https://github.com/otavioschwanck/arrow.nvim' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' }
}

require('mini.icons').setup()
require('mini.files').setup()
require('arrow').setup({
    show_icons = true,
    leader_key = ';'
})

vim.keymap.set('n', '<leader>f', MiniFiles.open)
vim.keymap.set('n', '<leader>q', ":quit<CR>")
vim.keymap.set('n', '<leader>w', ":write<CR>")

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

vim.cmd("colorscheme kanagawa-wave")

vim.lsp.enable({
    'lua_ls',
    'gopls',
    'pyright',
    'clangd',
    'ts_ls',
    'templ',
    'zls'
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


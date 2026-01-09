function! OpenCompletion()
    if !pumvisible() && (luaeval('vim.bo.omnifunc') == 'v:lua.vim.lsp.omnifunc')
        call feedkeys("\<C-x>\<C-o>", "n")
    endif
endfunction

autocmd InsertCharPre * call OpenCompletion()


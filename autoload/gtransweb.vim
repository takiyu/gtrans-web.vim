scriptencoding utf-8
" Escape user settings
let s:saved_cpo = &cpo
set cpo&vim

" ------------------------------ Private variables -----------------------------
""" File paths
let s:plugin_dir_path    = expand('<sfile>:p:h')
let s:python_dir_path    = resolve(s:plugin_dir_path . '/../python')
let s:gtansweb_py        = resolve(s:python_dir_path . '/gtransweb.py')
let s:gtansweb_server_py = resolve(s:python_dir_path . '/gtransweb_server.py')
let s:gtansweb_client_py = resolve(s:python_dir_path . '/gtransweb_client.py')

""" Translation texts
let s:src_text = ''
let s:tgt_text = ''

""" Server status
let s:server_awoken = 1
let s:client_persist = 0

" ------------------------------ Public functions ------------------------------
""" Main translation function (Python call)
function! gtransweb#translate(src_text)
    let s:src_text = a:src_text
    if g:gtransweb#async_mode == 0
        " Synchronous call
        exec 'pyfile ' . s:gtansweb_py
    else
        " Asynchronous call
        exec 'pyfile ' . s:gtansweb_client_py
        if s:server_awoken == 0
            " If failed to connect server, start new server process
            echomsg 'Start gtransweb server process'
            call vimproc#system_bg(g:gtransweb#python_path . ' ' .
                                 \ s:gtansweb_server_py .
                                 \ ' --port ' . g:gtransweb#server_port)
            " Connect via client script again (persistently)
            let s:client_persist = 1
            exec 'pyfile ' . s:gtansweb_client_py
            let s:client_persist = 0
        endif
        if s:server_awoken == 0
            echomsg 'Failed to start gtransweb server'
        endif
    endif
    return s:tgt_text
endfunction

""" Decorate result text of translation
function! gtransweb#decorate_result(src_text, tgt_text)
    let l:text = "Result text (" . g:gtransweb#tgt_lang . ")\n".
               \ "------------------\n". a:tgt_text . "\n\n" .
               \ "Source text (" . g:gtransweb#src_lang . ")\n" .
               \ "------------------\n". a:src_text
    return l:text
endfunction


""" Show text in another window named `g:gtransweb#window_name`
function! gtransweb#show_preview(text)
    " Go to another window
    let l:nb = bufnr(g:gtransweb#window_name)
    let l:wi = index(tabpagebuflist(tabpagenr()), l:nb)
    if l:nb > 0 && l:wi >= 0
        " Move in current tab
        execute (l:wi + 1) . 'wincmd w'
    else
        " Create new buffer
        execute 'split ' . g:gtransweb#window_name
    endif

    " Clean up, set text and resize window
    silent normal ggdG
    silent put = a:text
    silent normal ggdd
    setlocal bufhidden=hide noswapfile noro nomodified filetype=rst
    execute 'resize ' . g:gtransweb#window_height
endfunction

" ------------------------------------------------------------------------------
" Restore user settings
let &cpo = s:saved_cpo
unlet s:saved_cpo

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

" ------------------------------ Public variables ------------------------------
""" Languages ('ja', 'en', ...)
let g:gtransweb#src_lang = 'auto'
let g:gtransweb#tgt_lang = 'auto'

""" Window
let g:gtransweb#window_name = 'translation_result'
let g:gtransweb#window_height = 10

let g:gtransweb#async_mode = 1
let g:gtransweb#python_path = 'python'
let g:gtransweb#server_port = 23148

" ------------------------------ Public functions ------------------------------
""" Main translation function (Python call)
function! GtransWeb(src_text)
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
            let l:pe = g:gtransweb#python_path . ' ' . s:gtansweb_server_py
            let l:pe = l:pe . ' --port ' . g:gtransweb#server_port
            call vimproc#system_bg(l:pe)
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

""" Call translation and put it into another window
function! GtransWebPreview(src_text)
    let l:text = GtransWeb(a:src_text)
    call s:ShowPreview(l:text)
endfunction

""" Set source and target languages
function! GtransWebSetLangs(src_lang, tgt_lang)
    let g:gtransweb#src_lang = a:src_lang
    let g:gtransweb#tgt_lang = a:tgt_lang
    return 'src -> tgt: ' . a:src_lang . ' -> ' . a:tgt_lang  " Debug text
endfunction

" ------------------------------ Private functions -----------------------------
""" Call f with selected text
function! s:CallRange(f)
    let l:tmp = @@               " Store
    silent normal gvy
    let l:ret = call(a:f, [@@])  " Call function
    let @@ = l:tmp               " Restore
    return ret
endfunction

""" Show text in another window named `g:gtransweb#window_name`
function! s:ShowPreview(text)
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
    setlocal bufhidden=hide noswapfile noro nomodified
    execute 'resize ' . g:gtransweb#window_height
endfunction

" ---------------------------------- Commands ----------------------------------
command! -nargs=1 GtransWeb             :echo GtransWeb(<f-args>)
command! -nargs=1 GtransWebPreview      :call GtransWebPreview(<f-args>)
command! -range   GtransWebRange        :echo s:CallRange('GtransWeb')
command! -range   GtransWebPreviewRange :call s:CallRange('GtransWebPreview')
command! -nargs=* GtransWebSetLangs     :call GtransWebSetLangs(<f-args>)
command! -nargs=0 GtransWebTest         :call gtransweb#GtransWebTest()

" ------------------------------------------------------------------------------
" Restore user settings
let &cpo = s:saved_cpo
unlet s:saved_cpo

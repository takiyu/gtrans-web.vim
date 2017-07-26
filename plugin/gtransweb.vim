scriptencoding utf-8
" Escape user settings
let s:saved_cpo = &cpo
set cpo&vim

" ------------------------------ Private variables -----------------------------
""" Execution paths
let s:plugin_path = expand('<sfile>:p:h')
let s:python_path = resolve(s:plugin_path.'/../python')
let s:gtansweb_py = resolve(s:python_path.'/gtransweb.py')

""" Languages ('ja', 'en', ...)
let s:src_lang = 'auto'
let s:tgt_lang = 'auto'
let s:src_text = ''

""" Window
let s:window_name = '__translation__'
let s:window_height = 10

" ------------------------------ Public functions ------------------------------
""" Main translation function (Python call)
function! GtransWeb(src_text)
    let s:src_text = a:src_text
    exec 'pyfile' s:gtansweb_py
    return s:t_text
endfunction

""" Call translation and put it into another window
function! GtransWebPreview(src_text)
    let l:text = GtransWeb(a:src_text)
    call ShowPreview(l:text)
endfunction

""" Set source and translation languages
function! GtransWebSetLangs(src_lang, tgt_lang)
    let s:src_lang = a:src_lang
    let s:tgt_lang = a:tgt_lang
    return 's -> t: ' . s:src_lang . ' -> ' . s:tgt_lang  " Debug text
endfunction

" ------------------------------ Private functions -----------------------------
function! s:CallRange(f)
    let l:tmp = @@               " Store
    silent normal gvy
    let l:ret = call(a:f, [@@])  " Call function
    let @@ = l:tmp               " Restore
    return ret
endfunction

function! ShowPreview(text)
    " Go to another window
    let l:nb = bufnr(s:window_name)
    if l:nb > 0
        let l:wi = index(tabpagebuflist(tabpagenr()), l:nb)
        if l:wi >= 0
            " Move in current tab
            execute (l:wi + 1) . 'wincmd w'
        else
            execute 'sbuffer ' . l:nb
        endif
    else
        " Create new buffer
        execute 'split ' . s:window_name
    endif

    " Remove previous text
    silent normal ggdG
    " Set text
    silent put = a:text
    " Remove first line
    silent normal ggdd

    setlocal bufhidden=hide noswapfile noro nomodified
    execute 'resize ' . s:window_height
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

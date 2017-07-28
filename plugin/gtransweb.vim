scriptencoding utf-8
" Escape user settings
let s:saved_cpo = &cpo
set cpo&vim

" ------------------------------ Public variables ------------------------------
""" Languages ('ja', 'en', ...)
let g:gtransweb#src_lang = 'auto'
let g:gtransweb#tgt_lang = 'auto'

""" Window
let g:gtransweb#window_name = 'translation_result'
let g:gtransweb#window_height = 10
let g:gtransweb#window_deco = 1

""" Asynchronous mode
let g:gtransweb#async_mode = 1
let g:gtransweb#python_path = 'python'
let g:gtransweb#server_port = 23148

" ------------------------------ Public functions ------------------------------
""" Translate passed text
function! GtransWeb(src_text)
    return gtransweb#translate(a:src_text)
endfunction

""" Call translation and put it into another window
function! GtransWebPreview(src_text)
    " Translation
    let l:text = GtransWeb(a:src_text)
    " Decoration
    if g:gtransweb#window_deco
        let l:text = gtransweb#decorate_result(a:src_text, l:text)
    endif
    " Show in another window
    call gtransweb#show_preview(l:text)
endfunction

""" Set source and target languages
function! GtransWebSetLangs(src_lang, tgt_lang)
    let g:gtransweb#src_lang = a:src_lang
    let g:gtransweb#tgt_lang = a:tgt_lang
endfunction

" ------------------------------ Private functions -----------------------------
""" Call function with passed arguments or a selected string
function! s:RangeHelper(f, ...)
    if a:0 == 0
        " Selected text
        let l:tmp = @@     " Store
        silent normal gvy
        let l:args = [@@]
        let @@ = l:tmp     " Restore
    else
        " Arguments
        let l:args = a:000
    endif
    return call(a:f, l:args)
endfunction

" ---------------------------------- Commands ----------------------------------
command! -nargs=? -range GtransWeb         :echo s:RangeHelper('GtransWeb', <f-args>)
command! -nargs=? -range GtransWebPreview  :call s:RangeHelper('GtransWebPreview', <f-args>)
command! -nargs=*        GtransWebSetLangs :call GtransWebSetLangs(<f-args>)
command! -nargs=0        GtransWebTest     :call gtransweb_test#run_test()

" ------------------------------------------------------------------------------
" Restore user settings
let &cpo = s:saved_cpo
unlet s:saved_cpo

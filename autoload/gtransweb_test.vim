scriptencoding utf-8
" Escape user settings
let s:saved_cpo = &cpo
set cpo&vim

" ------------------------------------ Tests -----------------------------------
""" Call function with print testing messages
function! s:TestFunction(f, ...)
    echomsg '--- Test: ' . a:f . '(' . join(a:000, ', ') . ')'
    let l:ret = call(a:f, a:000)
    echomsg ' >> ' . l:ret
endfunction

""" Test functions
function! gtransweb_test#run_test()
    echomsg '========== Synchronous Mode Test =========='
    call s:TestFunction('GtransWebSetLangs', 'auto', 'auto')
    call s:TestFunction('GtransWeb', 'This is a pen.')
    call s:TestFunction('GtransWeb', 'これはペンです。')
    call s:TestFunction('GtransWebSetLangs', 'ja', 'en')
    call s:TestFunction('GtransWeb', '眠い。')
    call s:TestFunction('GtransWebSetLangs', 'en', 'ja')
    call s:TestFunction('GtransWeb', 'I am tired.')
    echomsg '========== Preview Test =========='
    call s:TestFunction('GtransWebPreview', 'Preview test')
endfunction

" ------------------------------------------------------------------------------
" Restore user settings
let &cpo = s:saved_cpo
unlet s:saved_cpo

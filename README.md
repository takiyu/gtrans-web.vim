# Gtrans-Web.vim #

Vim plugin which helps you use Google translation website.


## Dependency ##
* Python (2.x or 3.x)

    Vim +python or +python3 is also needed.
    
    Note: If your python dose not support `asyncio` package, install `trollius`.
      
* PhantomJS
* Selenium (Python bindings)
* vimproc (for asynchronous mode)

## Usage ##
Exanple of `.vimrc`

```vim
let g:gtransweb_async_mode = 1           " Asynchronous mode
let g:gtransweb_src_lang = 'en'          " Source language for translation
let g:gtransweb_tgt_lang = 'ja'          " Target language for translation
vnoremap <C-g>t :GtransWebPreview<CR>    " Translate selected text and preview
vnoremap <C-g>r :GtransWebReplace<CR>    " Translate selected text and replace
nnoremap <C-g>s :GtransWebSwapLangs<CR>  " Swap source and target languages
```

## Others ##
This plugin is tested on few environments.

I hope your pull requests.

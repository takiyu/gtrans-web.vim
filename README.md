# Gtrans-Web.vim #

Vim plugin which helps you use the Google translation website.


## Dependency ##
* Python (2.x or 3.x)

    Vim +python or +python3 is also needed.

## Usage ##
Exanple of `.vimrc`

```vim
let g:gtransweb_src_lang = 'en'          " Source language for translation
let g:gtransweb_tgt_lang = 'ja'          " Target language for translation
vnoremap <C-g>t :GtransWebPreview<CR>    " Translate selected text and preview
vnoremap <C-g>r :GtransWebReplace<CR>    " Translate selected text and replace
nnoremap <C-g>s :GtransWebSwapLangs<CR>  " Swap source and target languages
```

## Screenshot ##
<img src="https://raw.githubusercontent.com/takiyu/gtrans-web.vim/master/screenshots/1.png">

## Others ##
This plugin is tested on few environments.

I hope your pull requests.

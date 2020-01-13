" -*- vim: set sts=2 sw=2 et fdm=marker: -------------  vim modeline -*-

" Basic Settings
syntax on
set termguicolors

" Plugins
so ~/.config/nvim/plug.vim
call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-unimpaired'

call plug#end()


" conventional-push.nvim - A Neovim plugin for conventional commits with interactive file selection
" Maintainer: Morass

if exists('g:loaded_conventional_push')
  finish
endif
let g:loaded_conventional_push = 1

" User configuration - conventional commit prefixes
if !exists('g:conventional_push_prefixes')
  let g:conventional_push_prefixes = ['chore', 'fix', 'docs', 'feat', 'test', 'refactor', 'style', 'build', 'perf', 'debug', 'ci', 'revert', 'merge']
endif

" Commands
command! ConventionalPush lua require('conventional-push').start()
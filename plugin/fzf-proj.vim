function! s:defn(var, val)
  if !exists(a:var)
    exec 'let '.a:var."='".a:val."'"
  endif
endfunction

" defaults
call s:defn("g:fzf#proj#project_dir", "$HOME/code")
call s:defn("g:fzf#proj#max_proj_depth", 1)
call s:defn("g:fzf#proj#project#open_new_tab", 1)
call s:defn("g:fzf#proj#fancy_separator", "→")

let s:git_dirty = "git status --porcelain"
let s:git_unsynced = "git diff master..HEAD --name-only"

command! -bang Grep            call fzf#proj#pre_grep(<bang>0)
command! -bang Projects        call fzf#proj#select_proj(<bang>0)
command!       GitDirty        call fzf#proj#git_files(s:git_dirty)
command!       GitUnsynced     call fzf#proj#git_files(s:git_unsynced)

noremap <plug>Projects :Projects<CR>
noremap <plug>TcdProjects :Projects!<CR>

noremap <plug>Grep :Grep<CR>
noremap <plug>GrepAll :Grep!<CR>

noremap <plug>GitDirty :GitDirty<CR>
noremap <plug>GitUnsynced :GitUnsynced<CR>

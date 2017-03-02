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

command! -bar -bang Grep            call fzf#proj#pre_grep(<bang>0)
command! -bar -bang Projects        call fzf#proj#select_proj(<bang>0)
command! -bar       GitDirty        call fzf#proj#git_files(s:git_dirty)
command! -bar       GitUnsynced     call fzf#proj#git_files(s:git_unsynced)

map <plug>Projects :Projects<CR>
map <plug>TProjects :Projects!<CR>

map <plug>Grep :Grep<CR>
map <plug>GrepAll :Grep!<CR>

map <plug>GitDirty :GitDirty<CR>
map <plug>GitUnsynced :GitUnsynced<CR>

function! s:defn(var, val)
  if !exists(a:var)
    exec 'let '.a:var."='".a:val."'"
  endif
endfunction

" defaults
call s:defn("g:fzf#proj#project_dir", "$HOME/code")
call s:defn("g:fzf#proj#max_proj_depth", 1)
call s:defn("g:fzf#proj#fancy_separator", "→")
call s:defn("g:fzf#proj#project#do", "fzf#proj#open_file")


let g:fzf#proj#project#open_projects = {}

let s:git_dirty = "git status --porcelain"
let s:git_unsynced = "git diff master..HEAD --name-only"

command! -bang Grep            call fzf#proj#pre_grep(<bang>0)
command! -bang Projects        call fzf#proj#select_proj(<bang>0, 0)
command! -bang TabnewProjects  call fzf#proj#select_proj(<bang>0, 1)
command!       NewProject      call fzf#proj#new_project()
command!       CloneProject    call fzf#proj#clone_project()
command!       GitDirty        call fzf#proj#git_files(s:git_dirty)
command!       GitUnsynced     call fzf#proj#git_files(s:git_unsynced)

noremap <plug>NewProject  :NewProject<CR>
noremap <plug>Projects    :Projects<CR>
noremap <plug>FProjects   :Projects!<CR>
noremap <plug>TNProjects  :TabnewProjects<CR>
noremap <plug>FTNProjects :TabnewProjects!<CR>

noremap <plug>Grep :Grep<CR>
noremap <plug>AllGrep :Grep!<CR>

noremap <plug>GitDirty :GitDirty<CR>
noremap <plug>GitUnsynced :GitUnsynced<CR>

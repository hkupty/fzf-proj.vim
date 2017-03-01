function! s:defn(var, val)
  if !exists(a:var)
    exec 'let '.a:var."='".a:val."'"
  endif
endfunction

" defaults
call s:defn("g:fzf_proj#project_dir", "$HOME/code")
call s:defn("g:fzf_proj#max_proj_depth", 1)
call s:defn("g:fzf_proj#project#open_new_tab", 1)
call s:defn("g:fzf_proj#fancy_separator", " → ")

let s:list_projects = "find ".g:fzf_proj#project_dir." -maxdepth ".(g:fzf_proj#max_proj_depth + 1)." -name '.git' -printf '%h\n'"
let s:git_dirty = "git status --porcelain"
let s:git_unsynced = "git diff master..HEAD --name-only"

function! s:grep_files(arg, path, bang)
  call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" ' . shellescape(a:arg) . ' ' . shellescape(a:path), 1, a:bang)
endfunction

" Must work on this..
function! s:pre_grep(tests, bang)
  call inputsave()
  let query = input("search " . (a:tests ? "all" : "code") . g:fzf_proj#fancy_separator)
  call inputrestore()
  call s:grep_files(query, a:tests ? "." : "src/", a:bang)
endfunction

function! s:open(args)
  let [_, fname] = a:args
  if fname =~ " "
    let [_, fname] = split(fname, ' ')
  endif
  exec "silent edit" fname
endfunction

function! s:go_to(args)
  let [data, fname] = a:args
  if g:fzf_proj#project#open_new_tab
    tabnew
  endif
  exec "tcd" fname
  exec "silent edit" fname
endfunction

function! s:select_projects(bang)
  return fzf#run(fzf#wrap('projects',{
   \ 'source':  s:list_projects,
   \ 'dir':     g:fzf_proj#project_dir,
   \ 'sink*':   function('s:go_to'),
   \ 'options': '+m --prompt="projects' . g:fzf_proj#fancy_separator . '" --header-lines=0 --expect=ctrl-e --tiebreak=index'}, a:bang))
endfunction

function! s:git_files(cmd, bang)
  return fzf#run(fzf#wrap('edited',{
   \ 'source':  a:cmd,
   \ 'dir':     getcwd(-1, 0),
   \ 'sink*':   function('s:open'),
   \ 'options': '+m --prompt="files' . g:fzf_proj#fancy_separator . '" --header-lines=0 --expect=ctrl-e --tiebreak=index'}, a:bang))
endfunction

command! -bar -bang Grep            call s:pre_grep(0, <bang>0)
command! -bar -bang GrepAll         call s:pre_grep(1, <bang>0)
command! -bar -bang Projects        call s:select_projects(<bang>0)
command! -bar -bang GitDirty        call s:git_files(s:git_dirty, <bang>0)
command! -bar -bang GitUnsynced     call s:git_files(s:git_unsynced, <bang>0)

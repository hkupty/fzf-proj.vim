
function! fzf#proj#fuzzy_msg(msg)
  if type(a:msg) == type([])
    let msg = join(a:msg, " ")
  else
    let msg = a:msg
  endif

  return msg." ".g:fzf_proj#fancy_separator." "
endfunction

function! fzf#proj#go_to_file(args)
  " Expects the result from fzf. Sometimes, the output may be a git output
  let [_, fname] = a:args
  if fname =~ " "
    let [_, fname] = split(fname, ' ')
  endif
  exec "silent edit" fname
endfunction

function! fzf#proj#go_to_proj(new_tab, args)
  " Expects a new tab modifier (which can be curried) and the result from fzf.
  let [_, fname] = a:args
  echom join(a:args, " - ")

  if a:new_tab
    tabnew
  endif

  exec 'tcd' fname
  exec 'silent edit' fname
endfunction

function! fzf#proj#grep(arg, path)
  call fzf#vim#grep('rg --column --line-number --no-heading --ignore-case --follow '.
  \                 '--glob "!.git/*" --color "always" ' .  shellescape(a:arg) . ' ' . shellescape(a:path), 0)
endfunction

function! fzf#proj#select_proj(bang)
  let GoTo = function('fzf#proj#go_to_proj', [a:bang])
  " We use the path instead of `.` so it returns an absolute path.
  let list_projects = "find ".expand(g:fzf_proj#project_dir)." -maxdepth ".(g:fzf_proj#max_proj_depth + 1)." -name '.git' -printf '%h\n'"
  return fzf#run(fzf#wrap('projects',{
   \ 'source':  list_projects,
   \ 'dir':     g:fzf_proj#project_dir,
   \ 'sink*':   GoTo,
   \ 'options': '+m --prompt="' . fzf#proj#fuzzy_msg('projects') . '" --header-lines=0 --expect=ctrl-e --tiebreak=index'}, 0))
endfunction

function! fzf#proj#git_files(cmd)
  return fzf#run(fzf#wrap('edited',{
   \ 'source':  a:cmd,
   \ 'dir':     getcwd(-1, 0),
   \ 'sink*':   function('fzf#proj#go_to_file'),
   \ 'options': '+m --prompt="' . fzf#proj#fuzzy_msg('files') . '" --header-lines=0 --expect=ctrl-e --tiebreak=index'}, 0))
endfunction

function! fzf#proj#pre_grep(bang)
  call inputsave()
  let query = input(fzf#proj#fuzzy_msg("search"))
  call inputrestore()
  call fzf#proj#grep(query,  ".")
endfunction


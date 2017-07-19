function! fzf#proj#exit_handler(cd, id, status, evt)
  if a:status == 0
    echo 'Success'
    exec "tcd ".a:cd
  else
    echom 'Failed with status code '.a:status
  endif
endfunction

function! fzf#proj#fuzzy_msg(msg)
  if type(a:msg) == type([])
    let msg = join(a:msg, " ")
  else
    let msg = a:msg
  endif

  return msg." ".g:fzf#proj#fancy_separator." "
endfunction

function! fzf#proj#open_file() dict
  exec "silent edit" self.fname
endfunction

function! fzf#proj#new_dir(args)
  let [_, fname] = a:args
  if fname =~ " "
    let [_, fname] = split(fname, ' ')
  endif
  call inputsave()
  let new_dir = input(fzf#proj#fuzzy_msg("new dir name"))
  call inputrestore()
  let full_dir_path = fname . '/' . new_dir
  call mkdir(full_dir_path)
  call jobstart(['git', 'init', '.'], {'cwd': full_dir_path, 'on_exit': function('fzf#proj#exit_handler', [full_dir_path])})
endfunction

function! fzf#proj#git_clone(git_url, args)
  let [_, fname] = a:args
  if fname =~ " "
    let [_, fname] = split(fname, ' ')
  endif
  if a:git_url ==# ''
    call inputsave()
    let git_url = input(fzf#proj#fuzzy_msg("new dir name"))
    call inputrestore()
  else:
    let git_url = a:git_url
  endif

  let proj_name = join(split(split(git_url, '/')[1], '\.')[:-2], '.')
  let full_dir_path = fname . '/'
  call mkdir(full_dir_path)
  call jobstart(['git', 'clone', git_url], {'cwd': full_dir_path, 'on_exit': function('fzf#proj#exit_handler', [full_dir_path . proj_name])})
endfunction

function! fzf#proj#go_to_file(args)
  " Expects the result from fzf. Sometimes, the output may be a git output
  let [_, fname] = a:args
  if fname =~ " "
    let [_, fname] = split(fname, ' ')
  endif
  exec "silent edit" fname
endfunction

function! fzf#proj#go_to_proj(bang, tab, args)
  " Expects a new tab modifier (which can be curried) and the result from fzf.
  let [_, fname] = a:args
  if get(g:fzf#proj#project#open_projects, fname, 0) == 0 || a:bang
    if a:tab
      tabnew
    endif
    let g:fzf#proj#project#open_projects[fname] = tabpagenr()
  else
    exec g:fzf#proj#project#open_projects[fname].'tabn'
  endif
  for [k, v] in items(g:fzf#proj#project#open_projects)
    if v == tabpagenr() && k != fname
      unlet g:fzf#proj#project#open_projects[k]
    endif
  endfor
  exec 'tcd '.fname
  let ctx = {'fname': fname}
  call function(g:fzf#proj#project#do, ctx)()
endfunction

function! fzf#proj#grep(arg, path)
  call fzf#vim#grep('rg --column --line-number --no-heading --ignore-case --follow '.
  \                 '--glob "!.git/*" --color "always" ' .  shellescape(a:arg) . ' ' . shellescape(a:path), 0)
endfunction

function! fzf#proj#select_proj(bang, tab)
  let GoTo = function('fzf#proj#go_to_proj', [a:bang, a:tab])
  " We use the path instead of `.` so it returns an absolute path.
  let list_projects = "find ".expand(g:fzf#proj#project_dir)." -maxdepth ".(g:fzf#proj#max_proj_depth + 1)." -name '.git' -printf '%h\n'"
  return fzf#run(fzf#wrap('projects',{
   \ 'source':  list_projects,
   \ 'dir':     g:fzf#proj#project_dir,
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


function! fzf#proj#new_project()
  let cmd = "find ".expand(g:fzf#proj#project_dir)." -maxdepth ".g:fzf#proj#max_proj_depth." -exec test '!' -e \"{}/.git*\" -a -d '{}' ';' -printf '%h\n' | sort -u"
  return fzf#run(fzf#wrap('project',{
   \ 'source':  cmd,
   \ 'dir':     g:fzf#proj#project_dir,
   \ 'sink*':   function('fzf#proj#new_dir'),
   \ 'options': '+m --prompt="' . fzf#proj#fuzzy_msg('root') . '" --header-lines=0 --expect=ctrl-e --tiebreak=index'}, 0))
endfunction

function! fzf#proj#clone_project(git_url)
  let cmd = "find ".expand(g:fzf#proj#project_dir)." -maxdepth ".g:fzf#proj#max_proj_depth." -exec test '!' -e \"{}/.git*\" -a -d '{}' ';' -printf '%h\n' | sort -u"
  return fzf#run(fzf#wrap('project',{
   \ 'source':  cmd,
   \ 'dir':     g:fzf#proj#project_dir,
   \ 'sink*':   function('fzf#proj#git_clone', [a:git_url]),
   \ 'options': '+m --prompt="' . fzf#proj#fuzzy_msg('root') . '" --header-lines=0 --expect=ctrl-e --tiebreak=index'}, 0))
endfunction

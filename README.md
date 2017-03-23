# fzf-proj.vim
Project navigation with fzf

## Defined commands

`:Projects` - Fuzzy-find your projects. Sets `tcd` to the selected folder.
`:Grep` - Prompts for a query and fuzzy-finds the results.
`:GitDirty` - Fuzzy-find on the dirty/uncommited files on your git project.
`:GitUnsynced` - Fuzzy-find on the unpushed files.

## Customizations

`g:fzf#proj#project_dir` - Sets the root project directory. Defaults to `~/code/`
`g:fzf#proj#max_proj_depth` - Sets the amount of folders between the root project directory and the projects, inclusively. Defaults to 1.
`g:fzf#proj#project#open_new_tab` - Whether `fzf-proj` should open a new tab on the selected project or do on the current tab. Defaults to 1.
`g:fzf#proj#fancy_separator` - A fancy, utf-8 arrow so your prompt looks better. Defaults to →.

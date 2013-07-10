"
" vim-niji - Yet another rainbow parentheses plugin.
"
"  Maintainer: Alastair Touw <alastair@touw.me.uk>
"     Website: http://github.com/amdt/vim-niji
"     License: Distributed under the same terms as Vim. See ':h license'.
"     Version: 1.0.2
" Last Change: 2013 Jun 02
"       Usage: See 'doc/niji.txt' or ':help niji' if installed.
"
" Niji follows the Semantic Versioning specification (http://semver.org).
"

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

function! niji#association_list_with_keys_and_values(list_a, list_b)
	" Assumes 'list_a' and 'list_b' are of equal length.
	let l:list = []

	for each in range(1, len(a:list_a))
		let l:list += [[a:list_a[each -1], a:list_b[each -1]]]
	endfor

	return l:list
endfunction

function! niji#normalised_colours(colour_set)
	" Takes a colour set in one of three formats and returns it in a
	" fourth. The four formats are described as follows:
	"
	" 1. A single list of colours: the same colours are used for both
	"    light and dark backgrounds, and both terminal and graphical
	"    variants of Vim.
	"
	"        [red, blue, green]
	"
	" 2. A list of a list of pairs: the same colours are used for both
	"    light and dark backgrounds, but different colours for terminal and
	"    graphical variants of Vim.
	"
	"        [[red, red1], [blue, blue1], [green, green1]]
	"
	" 3. A dictionary of two lists of colours: different colours are used
	"    for light and dark backgrounds, but the same colours are used for
	"    both terminal and graphical variants of Vim.
	"
	"        {‘light_colours’: [red, blue, green],
	"        \ ‘dark_colours’: [orange, purple, yellow]}
	"
	" 4. A dictionary of two lists of a list of pairs: different colours
	"    are used for both light and dark backgrounds, and both terminal
	"    and graphical variants of vim.
	"
	"        {‘light_colours’: [[red, red1], [blue, blue1], [green, green1]],
	"        \ ‘dark_colours’: [[orange, orange1], [purple, purple1], [yellow, yellow1]]}
	"
	" Assumes the colour sets are correctly formed.
	if type(a:colour_set) == type({})
		if type(a:colour_set['light_colours'][0]) == type('')
			return {'light_colours': niji#association_list_with_keys_and_values(a:colour_set.light_colours, a:colour_set.light_colours),
			      \ 'dark_colours': niji#association_list_with_keys_and_values(a:colour_set.dark_colours, a:colour_set.dark_colours)}
		else
			return a:colour_set
		endif
	elseif type(a:colour_set) == type([])
		if type(a:colour_set[0]) == type([])
			return {'light_colours': a:colour_set,
			      \ 'dark_colours': a:colour_set}
		elseif type(a:colour_set[0]) == type('')
			return {'light_colours': niji#association_list_with_keys_and_values(a:colour_set, a:colour_set),
			      \ 'dark_colours': niji#association_list_with_keys_and_values(a:colour_set, a:colour_set)}
		endif
	endif
endfunction

function! niji#solarized_colours()
	" Solarized (blue, violet, magenta, red, orange, yellow)
	let l:solarized_guifg_colours = ['#268bd2',
	                               \ '#6c71c4',
	                               \ '#d33682',
	                               \ '#dc322f',
	                               \ '#cb4b16',
	                               \ '#b58900']

	if g:solarized_termcolors != 256 && &t_Co >= 16
		let l:solarized_ctermfg_colours = [4, 13, 5, 1, 9, 3]
	elseif g:solarized_termcolors == 256
		let l:solarized_ctermfg_colours = [33, 61, 125, 124, 166, 136]
	else
		let l:solarized_ctermfg_colours = ['DarkBlue',
		                                 \ 'LightMagenta',
		                                 \ 'DarkMagenta',
		                                 \ 'DarkRed',
		                                 \ 'LightRed',
		                                 \ 'DarkYellow']
	endif

	return niji#association_list_with_keys_and_values(l:solarized_ctermfg_colours,
	                                                \ l:solarized_guifg_colours)
endfunction

function! niji#lisp_colours()
	return {'light_colours': [['red', 'red3'],
	                        \ ['darkyellow', 'orangered3'],
	                        \ ['darkgreen', 'orange2'],
	                        \ ['blue', 'yellow3'],
	                        \ ['darkmagenta', 'olivedrab4'],
	                        \ ['red', 'green4'],
	                        \ ['darkyellow', 'paleturquoise3'],
	                        \ ['darkgreen', 'deepskyblue4'],
	                        \ ['blue', 'darkslateblue'],
	                        \ ['darkmagenta', 'darkviolet']],
	      \ 'dark_colours': [['red', 'red1'],
	                       \ ['yellow', 'orange1'],
	                       \ ['green', 'yellow1'],
	                       \ ['cyan', 'greenyellow'],
	                       \ ['magenta', 'green1'],
	                       \ ['red', 'springgreen1'],
	                       \ ['yellow', 'cyan1'],
	                       \ ['green', 'slateblue1'],
	                       \ ['cyan', 'magenta1'],
	                       \ ['magenta', 'purple1']]}
endfunction

function! niji#legacy_colours()
	return [['brown', 'RoyalBlue3'],
	      \ ['Darkblue', 'SeaGreen3'],
	      \ ['darkgray', 'DarkOrchid3'],
	      \ ['darkgreen', 'firebrick3'],
	      \ ['darkcyan', 'RoyalBlue3'],
	      \ ['darkred', 'SeaGreen3'],
	      \ ['darkmagenta', 'DarkOrchid3'],
	      \ ['brown', 'firebrick3'],
	      \ ['gray', 'RoyalBlue3'],
	      \ ['black', 'SeaGreen3'],
	      \ ['darkmagenta', 'DarkOrchid3'],
	      \ ['Darkblue', 'firebrick3'],
	      \ ['darkgreen', 'RoyalBlue3'],
	      \ ['darkcyan', 'SeaGreen3'],
	      \ ['darkred', 'DarkOrchid3'],
	      \ ['red', 'firebrick3']]
endfunction

function! niji#rainbow_parenthesise()
	if exists('g:niji_always_match')
		let l:matching_characters = g:niji_always_match
	elseif exists('g:niji_' . &ft . '_characters')
		let l:matching_characters = eval('g:niji_' . &ft . '_characters')
	else
		let l:matching_characters = eval('l:' . &ft . '_characters')
	endif

	if exists('g:niji_always_highlight')
		let l:colour_set = g:niji_always_highlight
	elseif exists('g:colors_name')
		if exists('g:niji_' . g:colors_name . '_colours')
			let l:colour_set = eval('g:niji_' . g:colors_name . '_colours')
		elseif exists('*niji#' . g:colors_name . '_colours')
			let l:colour_set = call('niji#' . g:colors_name . '_colours', [])
		endif
	elseif exists('g:niji_use_legacy_colours')
		let l:colour_set = call('niji#legacy_colours', [])
	else
		let l:colour_set = call('niji#lisp_colours', [])
	endif

	call niji#highlight(l:matching_characters,
	                  \ reverse(niji#normalised_colours(l:colour_set)[&bg == 'light' ? 'light_colours' : 'dark_colours']))
endfunction

function! niji#highlight(matching_characters, colour_set)
	for character_pair in a:matching_characters
		for each in range(1, len(a:colour_set))
			execute printf('syntax region Niji_paren%s matchgroup=Niji_paren_level%s start=/%s/ end=/%s/ contains=ALLBUT,%s',
			          \ string(each),
			          \ string(each),
			          \ character_pair[0],
			          \ character_pair[1],
			          \ join(map(filter(range(1, len(a:colour_set)),
			                          \ each == 1 ? 'v:val != len(a:colour_set)' : 'v:val != each - 1'),
			                   \ '"Niji_paren" . v:val'),
			               \ ','))
		endfor
	endfor

	for each in range(1, len(a:colour_set))
		execute printf('highlight default Niji_paren_level%s ctermfg=%s guifg=%s',
		             \ string(each),
		             \ a:colour_set[each - 1][0],
		             \ a:colour_set[each - 1][1])
	endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

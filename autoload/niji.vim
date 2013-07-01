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

function niji#association_list_with_keys_and_values(list_a, list_b)
	" Assumes 'list_a' and 'list_b' are of equal length.
	let l:list = []

	for each in range(1, len(a:list_a))
		let l:list += [[a:list_a[each -1], a:list_b[each -1]]]
	endfor

	return l:list
endfunction

function niji#solarized_colours()
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

function niji#set_colours()
	if exists('g:niji_' . g:colors_name . '_colours')
		" If the user has specified colours specific to this colorscheme, use
		" those
		let s:current_colour_set = eval('g:niji_' . g:colors_name . '_colours')
	elseif exists('g:niji_colours')
		" If the user has a default colour set, use it
		let s:current_colour_set = eval('g:niji_colours')
	elseif exists('*niji#' . g:colors_name . '_colours')
		" Use a function to get the proper colours for the current
		" colorscheme if that function exists
		let s:current_colour_set = eval('niji#' . g:colors_name . '_colours()')
	else
		" Use the default colours
		let s:current_colour_set = &bg == 'dark'
		                                \ ? [['red', 'red1'],
		                                   \ ['yellow', 'orange1'],
		                                   \ ['green', 'yellow1'],
		                                   \ ['cyan', 'greenyellow'],
		                                   \ ['magenta', 'green1'],
		                                   \ ['red', 'springgreen1'],
		                                   \ ['yellow', 'cyan1'],
		                                   \ ['green', 'slateblue1'],
		                                   \ ['cyan', 'magenta1'],
		                                   \ ['magenta', 'purple1']]
		                                \ : [['red', 'red3'],
		                                   \ ['darkyellow', 'orangered3'],
		                                   \ ['darkgreen', 'orange2'],
		                                   \ ['blue', 'yellow3'],
		                                   \ ['darkmagenta', 'olivedrab4'],
		                                   \ ['red', 'green4'],
		                                   \ ['darkyellow', 'paleturquoise3'],
		                                   \ ['darkgreen', 'deepskyblue4'],
		                                   \ ['blue', 'darkslateblue'],
		                                   \ ['darkmagenta', 'darkviolet']]
	endif


	" We need a list of pairs to set up highlighting (a list with 1+ lists of
	" two items each, the first for terminal highlighting and the second for gui
	" highlighting)

	" If we have a map, assume it has 'light' and 'dark' keys and choose the
	" right one based on the current background
	if type(s:current_colour_set) == type({})
		let l:temp_colour_set = s:current_colour_set[&bg]
		unlet s:current_colour_set
		let s:current_colour_set = l:temp_colour_set
	endif

	" If we have a list of strings, make a list of pairs of strings by
	" duplicating each and wrapping the pairs in a list
	if type(s:current_colour_set) == type([]) &&
	      \ len(s:current_colour_set) &&
	      \ type(s:current_colour_set[0]) == type('')
		let l:temp_colour_set = niji#association_list_with_keys_and_values(s:current_colour_set, s:current_colour_set)
		unlet s:current_colour_set
		let s:current_colour_set = l:temp_colour_set
	endif

	call reverse(s:current_colour_set)
endfunction

function niji#rainbow_parenthesise()
	if !exists('g:niji_matching_characters')
		let g:niji_matching_characters = [['(', ')'],
		                                \ ['\[', '\]'],
		                                \ ['{', '}']]
	endif

	call niji#set_colours()
	call niji#highlight(g:niji_matching_characters, s:current_colour_set)
endfunction

function niji#highlight(matching_characters, colour_set)
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

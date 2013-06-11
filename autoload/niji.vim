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

" Assumes 'list_a' and 'list_b' are of equal length.
function! niji#association_list_with_keys_and_values(list_a, list_b)
	let l:list = []

	for each in range(1, len(a:list_a))
		let l:list += [[a:list_a[each -1], a:list_b[each -1]]]
	endfor

	return l:list
endfunction

function! niji#get_solarized_colours()
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

function! niji#set_colours()
	if exists('g:niji_use_legacy_colours') && g:niji_use_legacy_colours
		" the original colour set
		let s:current_colour_set = [['brown', 'RoyalBlue3'],
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
		" use a function to get the proper colours for the current
		" colorscheme if the function exists
	elseif exists('*niji#get_' . g:colors_name . '_colours')
		let s:current_colour_set = eval('niji#get_' . g:colors_name . '_colours()')
	else
		" the default colours
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
endfunction

function! niji#set_matching_charcaters()
	let g:niji_matching_characters = [['(', ')'],
	                                \ ['\[', '\]'],
	                                \ ['{', '}']]
endfunction

function! niji#highlight()
	" Niji needs two variables to highlight matches
	" 1) Which characters to highlight (g:niji_matching_characters)
	" 2) Which colours to use (g:niji_light_colours or g:niji_dark_colours)
	" If these aren't set, we'll provide the best defaults possible
	" for more options see `:help niji-configuration`
	if !exists('g:niji_matching_characters')
		call niji#set_matching_charcaters()
	endif

	if exists('g:niji_' . &bg . '_colours')
    let s:current_colour_set = eval('g:niji_' . &bg . '_colours')
  else
		call niji#set_colours()
	endif

	call reverse(s:current_colour_set)

	for character_pair in g:niji_matching_characters
		for each in range(1, len(s:current_colour_set))
			execute printf('syntax region Niji_paren%s matchgroup=Niji_paren_level%s start=/%s/ end=/%s/ contains=ALLBUT,%s',
			          \ string(each),
			          \ string(each),
			          \ character_pair[0],
			          \ character_pair[1],
			          \ join(map(filter(range(1, len(s:current_colour_set)),
			                          \ each == 1 ? 'v:val != len(s:current_colour_set)' : 'v:val != each - 1'),
			                   \ '"Niji_paren" . v:val'),
			               \ ','))
		endfor
	endfor

	for each in range(1, len(s:current_colour_set))
		execute printf('highlight default Niji_paren_level%s ctermfg=%s guifg=%s',
		             \ string(each),
		             \ s:current_colour_set[each - 1][0],
		             \ s:current_colour_set[each - 1][1])
	endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

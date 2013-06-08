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

function! niji#highlight()

	" Takes two lists and returns an association list of which the keys are the
	" elements of 'list_a' and the values those of 'list_b'.
	"
	" Assumes 'list_a' and 'list_b' are of equal length.
	function! s:assoc(list_a, list_b)
		let l:list = []

		for each in range(1, len(a:list_a))
			let l:list += [[a:list_a[each -1], a:list_b[each -1]]]
		endfor

		return l:list
	endfunction

	if !exists('g:niji_matching_characters')
		let g:niji_matching_characters = [['(', ')'],
		                                \ ['\[', '\]'],
		                                \ ['{', '}']]
	endif

	let s:niji_lisp_colours = {'light_colours': [['red', 'red3'],
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

	let s:legacy_colours = [['brown', 'RoyalBlue3'],
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

	" blue, violet, magenta, red, orange, yellow
	if g:colors_name == 'solarized' && !exists('g:niji_solarized_colours')
		let s:solarized_guifg_colours = ['#268bd2',
		                     \ '#6c71c4',
		                     \ '#d33682',
		                     \ '#dc322f',
		                     \ '#cb4b16',
		                     \ '#b58900']

		if g:solarized_termcolors != 256 && &t_Co >= 16
			let s:solarized_ctermfg_colours = [4, 13, 5, 1, 9, 3]
		elseif g:solarized_termcolors == 256
			let s:solarized_ctermfg_colours = [33, 61, 125, 124, 166, 136]
		else
			let s:solarized_ctermfg_colours = ['DarkBlue',
			                                 \ 'LightMagenta',
			                                 \ 'DarkMagenta',
			                                 \ 'DarkRed',
			                                 \ 'LightRed',
			                                 \ 'DarkYellow']
		endif

		let g:niji_solarized_colours = s:assoc(s:solarized_ctermfg_colours,
		                                        \ s:solarized_guifg_colours)
	endif

	for colour_set in [s:niji_lisp_colours['light_colours'],
	                 \ s:niji_lisp_colours['dark_colours'],
	                 \ s:legacy_colours,
	                 \ g:niji_solarized_colours]
		call reverse(colour_set)
	endfor

	if exists('g:niji_use_legacy_colours')
		let s:current_colour_set = s:legacy_colours
	elseif exists('g:niji_' . g:colors_name . '_colours')
		let s:current_colour_set = eval('g:niji_' . g:colors_name . '_colours')
	elseif exists('g:niji_' . g:colors_name . '_' . &bg . '_colours')
		let s:current_colour_set = eval('g:niji_' . g:colors_name . '_' . &bg . '_colours')
	else
		let s:current_colour_set = &bg == 'dark' ? s:niji_lisp_colours['dark_colours'] : s:niji_lisp_colours['light_colours']
	endif

	for character_pair in g:niji_matching_characters
		for each in range(1, len(s:current_colour_set))
			execute printf('syntax region paren%s matchgroup=level%s start=/%s/ end=/%s/ contains=ALLBUT,%s',
			          \ string(each),
			          \ string(each),
			          \ character_pair[0],
			          \ character_pair[1],
			          \ join(map(filter(range(1, len(s:current_colour_set)),
			                          \ each == 1 ? 'v:val != len(s:current_colour_set)' : 'v:val != each - 1'),
			                   \ '"paren" . v:val'),
			               \ ','))
		endfor
	endfor

	for each in range(1, len(s:current_colour_set))
		execute printf('highlight default level%s ctermfg=%s guifg=%s',
		             \ string(each),
		             \ s:current_colour_set[each - 1][0],
		             \ s:current_colour_set[each - 1][1])
	endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

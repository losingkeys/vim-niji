How to Contribute
=================

The source code and issue tracking for Niji are hosted on its [GitHub project
page](https://github.com/amdt/vim-niji).

For known issues (and to report your own), please see
[the issue tracking page](https://github.com/amdt/vim-niji/issues).

If you feel that Niji can be improved, pull requests are appreciated and humbly
requested. Before you begin, please `checkout` the `develop` branch and see
whether your problem persists there. If it does, please submit your pull
request on to the `develop` branch.

Adding support for colorschemes
-------------------------------

If Niji doesn't have support for your colorscheme, it'll use some
default colors.  If you find these distracting or don't like them, you
might want to add support for your colorscheme.

To do this, follow the instructions above, then add a function to
`autoload/niji.vim` that is named after your colorscheme and returns a
list containing any number two-item lists.  The first item in each small
list is the terminal colour (see `:help highlight-ctermfg` for more info)
and the second item is the graphical vim colour (see `:help
highlight-guifg`).  The simplest example is below, for the 'reallynice'
colorscheme (to find out what your colorscheme is called, run
`:colorscheme` with it enabled):
```viml
  function! niji#get_reallynice_colours()
    return [['red', 'red1'],
          \ ['yellow', 'orange1'],
          \ ['green', 'yellow1'],
          \ ['cyan', 'greenyellow'],
          \ ['magenta', 'green1'],
          \ ['red', 'springgreen1'],
          \ ['yellow', 'cyan1'],
          \ ['green', 'slateblue1'],
          \ ['cyan', 'magenta1'],
          \ ['magenta', 'purple1']]
  endfunction
```
Remember to follow the `niji#get_<colorschemename>_colours()` naming
scheme, and to return a list of small lists of two colors (the same, but
in different formats for the terminal and the GUI, respectively).

Note: It's useful to be able to use a function to return the colors
because you can check system variables like `bg` to see if the
background is light or dark or `t_Co` to see how manu colours the
terminal supports.  For an example of this, see [the original function
for solarized colorscheme
support](https://github.com/joshuarh/vim-niji/blob/7acf347f93f5a8ac80c7b1edf72fc099a4153b9f/autoload/niji.vim#L30-L54).

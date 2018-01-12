require "curses" # require the curses gem
include Curses   # mixin curses

# The next three methods are provided by including the Curses module.

init_screen      # starts curses visual mode
getch            # reads a single character from stdin
close_screen     # closes the ncurses screen

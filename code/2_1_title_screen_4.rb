$LOAD_PATH.unshift "." # makes requiring files easier

require "pp"
require "curses"
require "ui"
require "game"

Game.new.run

$LOAD_PATH.unshift "."

require "curses"
require "yaml"
require "pp"
require "player"
require "attribute_generator"
require "ui"
require "role"
require "race"
require "gender"
require "alignment"
require "selection_screen"
require "game"
require "title_screen"
require "data_loader"
require "messages"

Game.new.run

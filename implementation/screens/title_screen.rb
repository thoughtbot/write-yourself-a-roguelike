require "curses"
require "screens/role_selection_screen"

class TitleScreen
  include Curses

  def initialize(game)
    @game = game
  end

  def tick
    render
    case getch
    when 'n' then RoleSelectionScreen.new(@game)
    when 'q' then nil
    else RoleSelectionScreen.new(@game, true)
    end
  end

  private

  def render
    clear
    setpos(1, 0)
    addstr("RHack, Copyright 2015")
    setpos(2, 7)
    addstr("By a daring developer, inspired by Nethack.")
    setpos(3, 7)
    addstr("See license for details.")
    setpos(6, 0)
    addstr("Shall I pick a character's race, role, gender and alignment for you? [ynq]")
  end
end


require "curses"
require "screens/title_screen"
require "player"

class RHack
  attr_reader :player
  include Curses

  def self.run
    new.run
  end

  def initialize
    @current_screen = TitleScreen.new(self)
    @player = Player.new
  end

  def run
    with_curses do
      while @current_screen
        @current_screen = @current_screen.tick
      end
    end
  end

  private

  def with_curses
    init_screen
    yield
  ensure
    close_screen
  end
end


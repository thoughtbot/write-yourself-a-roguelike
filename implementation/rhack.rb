require "curses"
require "screens/title_screen"
require "player"

class RHack
  attr_reader :player
  include Curses

  MESSAGES_FILE = "data/messages.yaml"

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

  def messages(key, replacements = {})
    @messages ||= load_messages
    message = @messages[key]
    replacements.reduce(message) do |message, (key, value)|
      message.gsub("%#{key}", value)
    end
  end

  private

  def with_curses
    init_screen
    noecho
    yield
  ensure
    close_screen
  end

  def load_messages
    YAML.load_file(MESSAGES_FILE).each_with_object({}) do |(key, message), hash|
      hash[key.to_sym] = message
    end
  end
end

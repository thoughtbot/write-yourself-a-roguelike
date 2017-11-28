class Game
  def initialize
    @ui = UI.new
    @options = { quit: false, randall: false } # variable for options

    # See selected options at exit
    at_exit do
      ui.close
      pp options
    end
  end

  def run
    title_screen
  end

  private

  attr_reader :ui, :options # Add attr_reader for options

  def title_screen
    TitleScreen.new(ui, options).render
    quit?
  end

  def quit?
    exit if options[:quit]
  end
end

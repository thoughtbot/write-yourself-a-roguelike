class Game
  def initialize
    @ui = UI.new
    at_exit { ui.close } # runs at program exit
  end

  def run
    title_screen
  end

  private

  attr_reader :ui

  def title_screen
    ui.message(0, 0, "Rhack, a NetHack clone")
    ui.message(1, 7, "by a daring developer")
    ui.choice_prompt(3, 0, "Shall I pick a character's race, role, gender and " + 
      "alignment for you? [ynq]", "ynq")
  end
end

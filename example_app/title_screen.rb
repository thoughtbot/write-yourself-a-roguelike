class TitleScreen
  def initialize(ui, options)
    @ui = ui
    @options = options
    @messages = Messages[:title]
  end

  def render
    ui.message(0, 0, messages[:name])
    ui.message(7, 1, messages[:by])
    handle_choice prompt
  end

  private

  attr_reader :ui, :options, :messages

  def prompt
    ui.choice_prompt(0, 3, messages[:pick_random], "ynq")
  end

  def handle_choice(choice)
    case choice
    when "q" then options[:quit] = true
    when "y" then options[:randall] = true
    end
  end
end

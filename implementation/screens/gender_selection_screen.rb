require "gender"
require "screens/alignment_selection_screen"

class GenderSelectionScreen
  include Curses

  GENDER_FILE = "data/genders.yaml"

  def initialize(game)
    @genders = YAML.load_file(GENDER_FILE).each_with_object({}) do |gender, hash|
      hash[gender["hotkey"]] = Gender.from_yaml(gender)
    end
    @game = game
  end

  def tick
    render
    choice = getch
    until @genders.key?(choice) || "*q".index(choice)
      choice = getch
    end

    case choice
    when 'q' then return nil
    when '*' then @game.player.gender = @genders.values.sample
    else @game.player.gender = @genders[choice]
    end

    AlignmentSelectionScreen.new(@game)
  end

  private

  def render
    clear
    setpos(0, 0)
    addstr("Choosing Gender")
    pick_msg = "Pick the gender of your #{@game.player.race.name} #{@game.player.role}"
    pos = cols - pick_msg.length - 2
    setpos(0, pos)
    addstr(pick_msg)

    @genders.each_with_index do |(hotkey, gender), index|
      setpos(2 + index, pos)
      addstr("#{hotkey} - #{gender.name}")
    end

    setpos(3 + @genders.length, pos)
    addstr("* - Random")
    setpos(4 + @genders.length, pos)
    addstr("q - Quit")
    setpos(5 + @genders.length, pos)
    addstr("(end)")
  end
end

require "race"
require "screens/gender_selection_screen"

class RaceSelectionScreen
  include Curses

  RACE_FILE = "data/races.yaml"

  def initialize(game, random = false)
    @role = game.player.role
    @races = YAML.load_file(RACE_FILE).select do |race|
      @role.race_choices.index(race["hotkey"])
    end.each_with_object({}) do |race, hash|
      hash[race["hotkey"]] = Race.from_yaml(race)
    end
    @game = game
    @random = random
  end

  def tick
    if @random
      @game.player.race = @races.values.sample
    else
      if @races.length == 1
        @game.player.race = @races.values.first
      else
        render
        choice = getch
        until @races.key?(choice) || "*q".index(choice)
          choice = getch
        end

        case choice
        when 'q' then return nil
        when '*' then @game.player.race = @races.values.sample
        else @game.player.race = @races[choice]
        end
      end
    end

    GenderSelectionScreen.new(@game, @random)
  end

  private

  def render
    clear
    setpos(0, 0)
    addstr("Choosing Race")
    pick_msg = "Pick the race of your #{@role}"
    pos = cols - pick_msg.length - 2
    setpos(0, pos)
    addstr(pick_msg)
    @races.each_with_index do |(hotkey, race), index|
      setpos(2 + index, pos)
      addstr("#{hotkey} - #{race.name}")
    end
    setpos(2 + @role.race_choices.length, pos)
    addstr("* - Random")
    setpos(3 + @role.race_choices.length, pos)
    addstr("q - Quit")
    setpos(4 + @role.race_choices.length, pos)
    addstr("(end)")
  end
end

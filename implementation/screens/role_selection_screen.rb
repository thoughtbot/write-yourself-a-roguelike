require "curses"
require "yaml"
require "role"
require "screens/race_selection_screen"

class RoleSelectionScreen
  include Curses

  ROLES_FILE = "data/roles.yaml"

  def initialize(game)
    @roles = YAML.load_file(ROLES_FILE).each_with_object({}) do |role, hash|
      hash[role["hotkey"]] = Role.from_yaml(role)
    end
    @game = game
  end

  def tick
    render
    choice = getch
    until @roles.key?(choice) || "*q".index(choice)
      choice = getch
    end

    case choice
    when 'q' then return nil
    when '*' then @game.player.role = @roles.values.sample
    else @game.player.role = @roles[choice]
    end

    RaceSelectionScreen.new(@game)
  end

  private

  def render
    clear
    setpos(0, 0)
    addstr("Choosing Character's Role")
    pick_msg = "Pick a role for your character"
    pos = cols - pick_msg.length - 2
    setpos(0, pos)
    addstr(pick_msg)
    @roles.each_with_index do |(hotkey, role), index|
      particle = "AEIOU".index(role.name[0]) ? "an" : "a"
      setpos(2 + index, pos)
      addstr("#{hotkey} - #{particle} #{role}")
    end
    setpos(2 + @roles.length, pos)
    addstr("* - Random")
    setpos(3 + @roles.length, pos)
    addstr("q - Quit")
    setpos(4 + @roles.length, pos)
    addstr("(end)")
  end
end


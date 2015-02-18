require "alignment"

class AlignmentSelectionScreen
  include Curses

  ALIGNMENTS_FILE = "data/alignments.yaml"

  def initialize(game)
    @game = game
    @alignments = YAML.load_file(ALIGNMENTS_FILE).select do |alignment|
      possible_alignments.index(alignment["hotkey"])
    end.each_with_object({}) do |alignment, hash|
      hash[alignment["hotkey"]] = Alignment.from_yaml(alignment)
    end
  end

  def tick
    render
    choice = getch
    until @alignments.key?(choice) || "*q".index(choice)
      choice = getch
    end

    case choice
    when 'q' then return nil
    when '*' then @game.player.alignment = @alignments.values.sample
    else @game.player.alignment = @alignments[choice]
    end

    nil
  end

  private

  def possible_alignments
    @possible_alignments ||=
      (@game.player.role.alignments.chars & @game.player.race.alignments.chars).
      join
  end

  def render
    clear
    setpos(0, 0)
    addstr("Choosing Alignment")
    pick_msg = "Pick the alignment of your #{@game.player.gender.name} #{@game.player.race.name} #{@game.player.role_name}"
    pos = cols - pick_msg.length - 2
    setpos(0, pos)
    addstr(pick_msg)

    @alignments.each_with_index do |(hotkey, alignment), index|
      setpos(2 + index, pos)
      addstr("#{hotkey} - #{alignment.name}")
    end

    setpos(3 + @alignments.length, pos)
    addstr("* - Random")
    setpos(4 + @alignments.length, pos)
    addstr("q - Quit")
    setpos(5 + @alignments.length, pos)
    addstr("(end)")
  end
end

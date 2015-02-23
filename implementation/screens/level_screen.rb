class LevelScreen
  include Curses

  def initialize(game)
    @game = game
  end

  def tick
    render
  end

  private

  def render_player_stats
    setpos(lines - 2, 0)
    addstr("%s the %s  St:%d Dx:%d Co:%d In:%d Wi:%d Ch:%d  %s" %
           [@game.player.name,
             @game.player.rank,
             @game.player.strength,
             @game.player.dexterity,
             @game.player.constitution,
             @game.player.intelligence,
             @game.player.wisdom,
             @game.player.charisma,
             @game.player.alignment])
    setpos(lines - 1, 0)
    addstr("Dlvl:%d  $:%d  HP:%d(%d) Pw:%d(%d) AC:%d  Exp:%d" %
           [
             @game.player.dungeon_level,
             @game.player.money,
             @game.player.current_hp,
             @game.player.max_hp,
             @game.player.current_energy,
             @game.player.max_energy,
             @game.player.armor_class,
             @game.player.level
           ])
  end

  def render_player
    setpos(@game.player.y, @game.player.x)
    addstr("@")
    setpos(@game.player.y, @game.player.x)
  end

  def render
    clear
    addstr(@game.messages(:intro, G: @game.player.god.title, d: @game.player.god.name, r: @game.player.rank))
    getch
    clear
    render_player_stats
    render_player

    c = getch
    while c != 'q'
      case c
      when 'j' then @game.player.y += 1
      when 'k' then @game.player.y -= 1
      when 'l' then @game.player.x += 1
      when 'h' then @game.player.x -= 1
      end
      clear
      render_player_stats
      render_player
      c = getch
    end
  end
end

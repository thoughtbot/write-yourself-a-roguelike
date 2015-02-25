require 'pp'
require 'pry'

class Room < Struct.new(:lx, :ly, :hx, :hy, :rtype, :rlit, :doorct, :fdoor, :nsubrooms, :irregular, :sbrooms, :resident)
  def initialize
    @sbrooms = Array.new
  end
end

class Rect < Struct.new(:lx, :ly, :hx, :hy)
end

class Pos < Struct.new(:glyph, :typ, :seenv, :flags, :horizontal, :lit, :waslit, :roomno, :edge)
  def initialize
    @glyph = 0
    @typ = 0
    @seenv = 0
    @flags = 0
    @horizontal = 0
    @lit = false
    @waslit = 0
    @roomno = 0
    @edge = 0
  end
end

class Dungeon
  STONE = 0
  VWALL = 1
  HWALL = 2
  TLCORNER = 3
  TRCORNER = 4
  BLCORNER = 5
  BRCORNER = 6
  ROOM = 24
  MAXNROFROOMS = 40
  COLNO = 80
  ROWNO = 21
  XLIM = 4
  YLIM = 3
  MAXRECT = 50
  attr_reader :rooms, :x_maze_max, :y_maze_max, :rect_cnt, :rect, :locations, :smeq, :nrooms, :doorindex

  def initialize
    @doorindex = 0
    @smeq = Array.new(MAXNROFROOMS, 0)
    @rooms = Array.new((MAXNROFROOMS + 1) * 2) { Room.new }
    @rooms[0].hx = -1
    @nrooms = 0
    @rect_cnt = 1
    @rect = [Rect.new(0, 0, COLNO-1, ROWNO-1)]
    @locations = Array.new(COLNO) { Array.new(ROWNO) { Pos.new } }

    @x_maze_max = COLNO-1
    if @x_maze_max % 2 != 0
      @x_maze_max -= 1
    end

    @y_maze_max = ROWNO-1
    if @y_maze_max % 2 != 0
      @y_maze_max -= 1
    end
  end

  def generate
    makerooms
    @locations.transpose.each do |row|
      row.each do |col|
        print case col.typ
        when STONE then " "
        when ROOM then "."
        when HWALL then "-"
        when VWALL then "|"
        when TRCORNER then "-"
        when TLCORNER then "-"
        when BRCORNER then "-"
        when BLCORNER then "-"
        end
      end
      puts
    end
  end

  private

  def makerooms
    tried_vault = false

    while (nrooms < MAXNROFROOMS) && rnd_rect
      if(nrooms >= (MAXNROFROOMS/6) && rand(2) != 0 && !tried_vault)
        tried_vault = true
      else
        return unless create_room
      end
    end
  end

  def create_room
    r1 = nil
    r2 = Rect.new

    trycnt = 0
    vault = false

    xlim = XLIM
    ylim = YLIM

    xabs = nil
    yabs = nil
    wtmp = nil
    htmp = nil

    loop do
      r1 = rnd_rect
      if !r1
        return false
      end

      hx = r1.hx
      hy = r1.hy
      lx = r1.lx
      ly = r1.ly

      if vault
        dx = dy = 1
      else
        dx = 2 + rand((hx-lx > 28) ? 12 : 8)
        dy = 2 + rand(4)
        if dx*dy > 50
          dy = 50/dx
        end
      end

      xborder = (lx > 0 && hx < COLNO - 1) ? 2*xlim : xlim+1
      yborder = (ly > 0 && hy < ROWNO - 1) ? 2*ylim : ylim+1

      if hx-lx < dx + 3 + xborder || hy-ly < dy + 3 + yborder
        r1 = nil
        next
      end

      xabs = lx + (lx > 0 ? xlim : 3) + rand(hx - (lx > 0 ? lx : 3) - dx - xborder + 1)
      yabs = ly + (ly > 0 ? ylim : 2) + rand(hy - (ly > 0 ? ly : 2) - dy - yborder + 1)

      if ly == 0 && hy >= (ROWNO - 1) && (nrooms == 0 || rand(nrooms) == 0) && (yabs + dy > ROWNO/2)
        yabs = rand(3) + 2
        if nrooms < 4 && dy > 1
          dy -= 1
        end
      end

      success, xabs, dx, yabs, dy, vault = check_room(xabs, dx, yabs, dy, vault)
      unless success
        r1 = nil
        next
      end

      wtmp = dx+1
      htmp = dy+1

      r2.lx = xabs - 1
      r2.ly = yabs - 1
      r2.hx = xabs + wtmp
      r2.hy = yabs + htmp

      break if trycnt > 100 || r1
      trycnt += 1
    end

    if !r1
      return false
    end

    r = split_rects(r1, r2)

    if !vault
      smeq[nrooms] = nrooms
      add_room(xabs, yabs, xabs+wtmp-1, yabs+htmp-1)
    else
      rooms[nrooms].lx = xabs
      rooms[nrooms].ly = yabs
    end

    true
  end

  def add_room(lowx, lowy, hix, hiy)
    croom = rooms[nrooms]
    do_room_or_subroom(croom, lowx, lowy, hix, hiy, true)

    croom = rooms[nrooms]
    croom.hx = -1
    @nrooms += 1
  end

  def do_room_or_subroom(croom, lowx, lowy, hix, hiy, is_room)
    if lowx == 0
      lowx = 1
    end

    if lowy == 0
      lowy = 1
    end

    if hix >= COLNO - 1
      hix = COLNO - 2
    end

    if hiy >= ROWNO - 1
      hiu = ROWNO - 2
    end

    #if(lit)

    (lowx-1).upto(hix+1) do |x|
      (lowy-1).upto(hiy+1) do |y|
        lev = locations[x][[y,0].max]
        lev.lit = true
      end
    end

    croom.rlit = true
    croom.lx = lowx
    croom.hx = hix
    croom.ly = lowy
    croom.hy = hiy
    croom.rtype = 0
    croom.doorct = 0
    croom.fdoor = doorindex
    croom.irregular = false
    croom.nsubrooms = 0
    # croom.sbrooms[0] = Room.new
    # if !special
    (lowx-1).upto(hix+1) do |x|
      (lowy-1).step(hiy+1, hiy - lowy + 2) do |y|
        locations[x][y].typ = HWALL
        locations[x][y].horizontal = true
      end
    end

    (lowx-1).step(hix+1, hix-lowx+2) do |x|
      lowy.upto(hiy) do |y|
        locations[x][y].typ = VWALL
        locations[x][y].horizontal = false
      end
    end

    lowx.upto(hix) do |x|
      lowy.upto(hiy) do |y|
        locations[x][y].typ = ROOM
      end
    end

    if is_room
      locations[lowx-1][lowy-1].typ = TLCORNER
      locations[hix+1][lowy-1].typ = TRCORNER
      locations[lowx-1][hiy+1].typ = BLCORNER
      locations[hix+1][hiy+1].typ = BRCORNER
    else
      # wallification
    end
  end

  def split_rects(r1, r2)
    old_r = r1
    remove_rect(r1)
    # TODO: walkd down since rect_cnt & rect[] will change...

    if r2.ly - old_r.ly - 1 > (old_r.hy < ROWNO - 1 ? 2 * YLIM : YLIM + 1) + 4
      r = old_r
      r.hy = r2.ly - 2
      add_rect(r)
    end

    if r2.lx - old_r.lx - 1 > (old_r.hx < COLNO - 1 ? 2 * XLIM : XLIM + 1) + 4
      r = old_r
      r.hx = r2.lx - 2
      add_rect(r)
    end

    if old_r.hy - r2.hy - 1 > (old_r.ly > 0 ? 2 * YLIM : YLIM + 1) + 4
      r = old_r
      r.ly = r2.hy + 2
      add_rect(r)
    end

    if old_r.hx - r2.hx - 1 > (old_r.lx > 0 ? 2 * XLIM : XLIM + 1) + 4
      r = old_r
      r.lx = r2.hx + 2
      add_rect(r)
    end
  end

  def add_rect(r)
    if rect_cnt >= MAXRECT
      return
    end

    if get_rect(r)
      return
    end

    rect[rect_cnt] = r
    @rect_cnt += 1
  end

  def remove_rect(r)
    ind = rect.index(r)
    if ind >= 0
      rect[ind] = rect[rect_cnt-1]
      @rect_cnt -= 1
    end
  end

  def get_rect(r)
    lx = r.lx
    ly = r.ly
    hx = r.hx
    hy = r.hy
    0.upto(rect_cnt - 1) do |i|
      rectp = rect[0]
      if lx >= rectp.lx && ly >= rectp.ly && hx <= rectp.hx && hy <= rectp.hy
        return rectp
      end
    end

    nil
  end

  def check_room(lowx, ddx, lowy, ddy, vault)
    hix = lowx + ddx
    hiy = lowy + ddy

    xlim = XLIM + (vault ? 1 : 0)
    ylim = YLIM + (vault ? 1 : 0)

    if lowx < 3
      lowx = 3
    end

    if lowy < 2
      lowy = 2
    end

    if hix > COLNO - 3
      hix = COLNO - 3
    end

    if hiy > ROWNO - 3
      hiy = ROWNO - 3
    end

    # chk

    if hix <= lowx || hiy <= lowy
      return false
    end

    (lowx - xlim).upto(hix + xlim) do |x|
      if x<= 0 || x >= COLNO
        next
      end

      y = lowy - ylim
      ymax = hiy + ylim
      if y < 0
        y = 0
      end

      if ymax >= ROWNO
        ymax = ROWNO - 1
      end

      ddx = hix - lowx
      ddy = hiy - lowy
    end

    [true, lowx, ddx, lowy, ddy, vault]
  end

  def rnd_rect
    if rect_cnt > 0
      rect[rand(rect_cnt)]
    end
  end
end

Dungeon.new.generate

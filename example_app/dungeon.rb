require 'pp'
require 'pry'

class Coord < Struct.new(:x, :y)
  def self.init
    new.tap do |coord|
      coord.x = 0
      coord.y = 0
    end
  end
end

class Rect < Struct.new(:lx, :ly, :hx, :hy)
  def self.init
    new.tap do |rect|
      rect.lx = 0
      rect.ly = 0
      rect.hx = 0
      rect.hy = 0
    end
  end
end

class Room < Rect; end

class Dungeon
  STONE = " "
  HWALL = "-"
  VWALL = "|"
  ROOM = "."
  MAXNROFROOMS = 40
  MAXRECT = 40

  COLNO = 80
  ROWNO = 21

  XLIM = 4
  YLIM = 3

  attr_reader :rect, :rooms, :locations

  def initialize
    @rooms = []
    @rect = [ Rect.new(0, 0, COLNO-1, ROWNO-1) ]

    @locations = Array.new(ROWNO) { Array.new(COLNO) { STONE} }
  end

  def print_rects
    grid = Array.new(ROWNO) { Array.new(COLNO) { " " } }
    @rect.each_with_index do |rect, index|
      char = (97 + index).chr
      rect.ly.upto(rect.hy) do |y|
        rect.lx.upto(rect.hx) do |x|
          grid[y][x] = char
        end
      end
      puts grid.map(&:join)
      puts
      puts
    end

    @locations.each_with_index do |row, y|
      row.each_with_index do |col, x|
        if col != STONE
          grid[y][x] = col
        end
      end
    end

    puts grid.map(&:join)
  end

  def print_rooms
    puts @locations.map(&:join)
  end

  def generate
    makerooms
    print_rooms
  end

  private

  def makerooms
    while (rooms.count < MAXNROFROOMS) && rect.any?
      puts "*" * 80
      puts
      print_rects
      gets
      return unless create_room
    end
  end

  def create_room
    xabs = nil
    yabs = nil
    wtmp = nil
    htmp = nil

    r1 = rect.sample
    r2 = Rect.init

    trycnt = 0

    xlim = XLIM
    ylim = YLIM

    loop do
      xaltmp = nil
      yaltmp = nil

      r1 = rect.sample
      if !r1
        return false
      end

      hx = r1.hx
      hy = r1.hy
      lx = r1.lx
      ly = r1.ly

      dx = 2 + rand((hx-lx > 28) ? 12 : 8)
      dy = 2 + rand(4)
      if dx*dy > 50
        dy = 50/dx
      end

      xborder = (lx > 0 && hx < COLNO - 1) ? 2*xlim : xlim+1
      yborder = (ly > 0 && hy < ROWNO - 1) ? 2*ylim : ylim+1

      if (hx-lx < (dx + 3 + xborder)) || (hy-ly < (dy + 3 + yborder))
        r1 = nil
        trycnt += 1
        break if trycnt > 100
        next
      end

      xabs = lx + (lx > 0 ? xlim : 3) + rand(hx - (lx > 0 ? lx : 3) - dx - xborder + 1)
      yabs = ly + (ly > 0 ? ylim : 2) + rand(hy - (ly > 0 ? ly : 2) - dy - yborder + 1)

      if ly == 0 && hy >= (ROWNO - 1) && (rooms.count == 0 || rand(rooms.count) == 0) && (yabs + dy > ROWNO/2)
        yabs = rand(3) + 2
        if rooms.count < 4 && dy > 1
          dy -= 1
        end
      end

      success, xabs, dx, yabs, dy = check_room(xabs, dx, yabs, dy)
      unless success
        r1 = nil
        trycnt += 1
        break if trycnt > 100
        next
      end

      wtmp = dx+1
      htmp = dy+1

      r2.lx = xabs - 1
      r2.ly = yabs - 1
      r2.hx = xabs + wtmp
      r2.hy = yabs + htmp

      trycnt += 1
      break if trycnt > 100 || r1
    end

    if !r1
      return false
    end

    r = split_rects(r1, r2)

    add_room(xabs, yabs, xabs+wtmp-1, yabs+htmp-1)

    true
  end

  def add_room(lowx, lowy, hix, hiy)
    croom = Room.init
    do_room_or_subroom(croom, lowx, lowy, hix, hiy, true)

    rooms << croom
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
      hiy = ROWNO - 2
    end

    croom.lx = lowx
    croom.hx = hix
    croom.ly = lowy
    croom.hy = hiy

    (lowy-1).step(hiy+1, hiy - lowy + 2) do |y|
      (lowx-1).upto(hix+1) do |x|
        locations[y][x] = HWALL
      end
    end

    lowy.upto(hiy) do |y|
      (lowx-1).step(hix+1, hix-lowx+2) do |x|
        locations[y][x] = VWALL
      end
    end

    lowy.upto(hiy) do |y|
      lowx.upto(hix) do |x|
        locations[y][x] = ROOM
      end
    end
  end

  def split_rects(r1, r2)
    old_r = r1.dup
    remove_rect(r1)

    (rect.count-1).downto(0) do |i|
      success, r = intersect?(rect[i], r2)
      if success
        split_rects(rect[i], r)
      end
    end

    if r2.ly - old_r.ly - 1 > (old_r.hy < ROWNO - 1 ? 2 * YLIM : YLIM + 1) + 4
      r = old_r.dup
      r.hy = r2.ly - 2
      add_rect(r)
    end

    if r2.lx - old_r.lx - 1 > (old_r.hx < COLNO - 1 ? 2 * XLIM : XLIM + 1) + 4
      r = old_r.dup
      r.hx = r2.lx - 2
      add_rect(r)
    end

    if old_r.hy - r2.hy - 1 > (old_r.ly > 0 ? 2 * YLIM : YLIM + 1) + 4
      r = old_r.dup
      r.ly = r2.hy + 2
      add_rect(r)
    end

    if old_r.hx - r2.hx - 1 > (old_r.lx > 0 ? 2 * XLIM : XLIM + 1) + 4
      r = old_r.dup
      r.lx = r2.hx + 2
      add_rect(r)
    end
  end

  def intersect?(r1, r2)
    if r2.lx > r1.hx || r2.ly > r1.hy || r2.hx < r1.lx || r2.hy < r1.ly
      return false
    end

    r3 = Rect.init
    r3.lx = (r2.lx > r1.lx ? r2.lx : r1.lx)
    r3.ly = (r2.ly > r1.ly ? r2.ly : r1.ly)
    r3.hx = (r2.hx > r1.hx ? r1.hx : r2.hx)
    r3.hy = (r2.hy > r1.hy ? r1.hy : r2.hy)

    if r3.lx > r3.hx || r3.ly > r3.hy
      return false
    end

    [true, r3]
  end

  def add_rect(r)
    if rect.count >= MAXRECT
      return
    end

    if get_rect(r)
      return
    end

    rect << r
  end

  def remove_rect(r)
    rect.delete(r)
  end

  def get_rect(r)
    lx = r.lx
    ly = r.ly
    hx = r.hx
    hy = r.hy
    0.upto(rect.count - 1) do |i|
      rectp = rect[i]
      if lx >= rectp.lx && ly >= rectp.ly && hx <= rectp.hx && hy <= rectp.hy
        return rectp
      end
    end

    nil
  end

  def check_room(lowx, ddx, lowy, ddy)
    hix = lowx + ddx
    hiy = lowy + ddy

    xlim = XLIM
    ylim = YLIM

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

    end

    ddx = hix - lowx
    ddy = hiy - lowy

    [true, lowx, ddx, lowy, ddy]
  end
end

seed = ENV["SEED"] || Random::DEFAULT.seed
srand(seed.to_i)
puts "SEED=#{seed}"
Dungeon.new.generate

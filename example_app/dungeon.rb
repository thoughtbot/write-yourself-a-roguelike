require 'pry'

class Rect < Struct.new(:lx, :ly, :hx, :hy); end

class Dungeon
  MAX_ROOM_COUNT = 40

  COLNO = 80
  ROWNO = 21

  XLIM = 4
  YLIM = 3

  def initialize
    @rects = [ Rect.new(0, 0, COLNO - 1, ROWNO - 1) ]
  end

  def generate
    make_rooms
  end

  private

  attr_reader :rects

  def make_rooms
    create_room
  end

  def create_room
    xlim = XLIM
    ylim = YLIM

    r1 = random_rect

    hx = r1.hx
    hy = r1.hy
    lx = r1.lx
    ly = r1.ly

    dx = 2 + rand((hx - lx > 8) ? 12 : 8)
    dy = 2 + rand(4)

    xborder = 5
    yborder = 4

    xabs = lx + (lx > 0 ? xlim : 3) + rand(hx - (lx > 0 ? lx : 3) - dx - xborder + 1)
    yabs = ly + (ly > 0 ? ylim : 2) + rand(hy - (ly > 0 ? ly : 2) - dy - yborder + 1)

    Rect.new(xabs - 1, yabs - 1, xabs + dx + 1, yabs + dy + 1)
  end

  def random_rect
    rects.sample
  end
end

puts Dungeon.new.generate

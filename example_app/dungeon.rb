require 'pp'
require 'pry'

class Rect
  attr_accessor :left, :top, :right, :bottom
  def initialize(left = 0, top = 0, right = 0, bottom = 0)
    @left = left
    @top = top
    @right = right
    @bottom = bottom
  end

  def invalid?
    left > right || top > bottom
  end

  def contained_in?(rect)
    left >= rect.left &&
      top >= rect.top &&
      right <= rect.right &&
      bottom <= rect.bottom
  end

  def exclude?(rect)
    rect.left > right ||
      rect.top > bottom ||
      rect.right < left ||
      rect.bottom < top
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

  attr_reader :rects, :rooms, :locations

  def initialize
    @rooms = []
    @rects = [ Rect.new(0, 0, COLNO-1, ROWNO-1) ]
    @locations = Array.new(ROWNO) { Array.new(COLNO) { STONE } }
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
    while (rooms.count < MAXNROFROOMS) && rects.any?
      return unless create_room
    end
  end

  def create_room
    xabs = nil
    yabs = nil
    wtmp = nil
    htmp = nil

    r1 = rects.sample
    r2 = Rect.new

    trycnt = 0

    loop do
      xaltmp = nil
      yaltmp = nil

      r1 = rects.sample
      if !r1
        return false
      end

      right = r1.right
      bottom = r1.bottom
      left = r1.left
      top = r1.top

      dx = 2 + rand((right-left > 28) ? 12 : 8)
      dy = 2 + rand(4)

      if dx*dy > 50
        dy = 50/dx
      end

      xborder = (left > 0 && right < COLNO - 1) ? 2 * XLIM : XLIM + 1
      yborder = (top > 0 && bottom < ROWNO - 1) ? 2 * YLIM : YLIM + 1

      if (right-left < (dx + 3 + xborder)) || (bottom-top < (dy + 3 + yborder))
        r1 = nil
        trycnt += 1
        break if trycnt > 100
        next
      end

      xabs = left + (left > 0 ? XLIM : 3) + rand(right - (left > 0 ? left : 3) - dx - xborder + 1)
      yabs = top + (top > 0 ? YLIM : 2) + rand(bottom - (top > 0 ? top : 2) - dy - yborder + 1)

      if top == 0 && bottom >= (ROWNO - 1) && (rooms.count == 0 || rand(rooms.count) == 0) && (yabs + dy > ROWNO/2)
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

      r2.left = xabs - 1
      r2.top = yabs - 1
      r2.right = xabs + wtmp
      r2.bottom = yabs + htmp

      trycnt += 1
      break if trycnt > 100 || r1
    end

    if !r1
      return false
    end

    split_rects(r1, r2)

    add_room(xabs, yabs, xabs+wtmp-1, yabs+htmp-1)

    true
  end

  def add_room(lowx, lowy, hix, hiy)
    lowx = 1 if lowx == 0
    lowy = 1 if lowy == 0
    hix = COLNO - 2 if hix >= COLNO - 1
    hiy = ROWNO - 2 if hiy >= ROWNO - 1

    room = Room.new(lowx, lowy, hix, hiy)

    (lowy-1).step(hiy+1, hiy - lowy + 2) do |y|
      (lowx-1).upto(hix+1) do |x|
        locations[y][x] = HWALL
      end
    end

    lowy.upto(hiy) do |y|
      (lowx-1).step(hix+1, hix-lowx+2) do |x|
        locations[y][x] = VWALL
      end

      lowx.upto(hix) do |x|
        locations[y][x] = ROOM
      end
    end

    rooms << room
  end

  def split_rects(r1, r2)
    rects.delete(r1)

    (rects.count-1).downto(0) do |i|
      r = intersect?(rects[i], r2)
      if r
        split_rects(rects[i], r)
      end
    end

    if r2.top - r1.top - 1 > (r1.bottom < ROWNO - 1 ? 2 * YLIM : YLIM + 1) + 4
      r = r1.dup
      r.bottom = r2.top - 2
      add_rect(r)
    end

    if r2.left - r1.left - 1 > (r1.right < COLNO - 1 ? 2 * XLIM : XLIM + 1) + 4
      r = r1.dup
      r.right = r2.left - 2
      add_rect(r)
    end

    if r1.bottom - r2.bottom - 1 > (r1.top > 0 ? 2 * YLIM : YLIM + 1) + 4
      r = r1.dup
      r.top = r2.bottom + 2
      add_rect(r)
    end

    if r1.right - r2.right - 1 > (r1.left > 0 ? 2 * XLIM : XLIM + 1) + 4
      r = r1.dup
      r.left = r2.right + 2
      add_rect(r)
    end
  end

  def intersect?(r1, r2)
    return false if r1.exclude?(r2)

    r3 = Rect.new(
      [r1.left, r2.left].max,
      [r1.top, r2.top].max,
      [r1.right, r2.right].min,
      [r1.bottom, r2.bottom].min
    )

    return false if r3.invalid?

    r3
  end

  def add_rect(r)
    return if rects.count >= MAXRECT
    return if get_rect(r)

    rects << r
  end

  def get_rect(r)
    rects.find { |rect| r.contained_in?(rect) }
  end

  def check_room(lowx, ddx, lowy, ddy)
    hix = lowx + ddx
    hiy = lowy + ddy

    lowx = [lowx, 3].max
    lowy = [lowy, 2].max
    hix = [hix, COLNO - 3].min
    hiy = [hiy, ROWNO - 3].min

    return false if hix <= lowx || hiy <= lowy

    (lowx - XLIM).upto(hix + XLIM) do |x|
      next if x <= 0 || x >= COLNO

      y = [lowy - YLIM, 0].max
      ymax = [hiy + YLIM, ROWNO - 1].min
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

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

class Room < Struct.new(:lx, :ly, :hx, :hy, :rtype, :rlit, :doorct, :fdoor, :nsubrooms, :irregular, :sbrooms, :resident)
  def self.init
    new.tap do |room|
      room.lx = 0
      room.ly = 0
      room.hx = 0
      room.hy = 0
      room.rtype = 0
      room.rlit = 0
      room.doorct = 0
      room.fdoor = 0
      room.nsubrooms = 0
      room.irregular = 0
      room.sbrooms = 0
      room.resident = 0
    end
  end

  def to_s
    "<#{lx}, #{ly}, #{hx}, #{hy}>"
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

class Pos < Struct.new(:glyph, :typ, :seenv, :flags, :horizontal, :lit, :waslit, :roomno, :edge)
  def self.init
    new.tap do |pos|
      pos.glyph = 0
      pos.typ = 0
      pos.seenv = 0
      pos.flags = 0
      pos.horizontal = 0
      pos.lit = false
      pos.waslit = 0
      pos.roomno = 0
      pos.edge = 0
    end
  end
end

class Dungeon
  DOORMAX = 120
  D_NODOOR = 0
  D_ISOPEN = 2
  D_CLOSED = 4
  D_LOCKED = 8

  SHOPBASE = 14

  LEFT = 1
  H_LEFT = 2
  CENTER = 3
  H_RIGHT = 4
  RIGHT = 5

  TOP = 1
  BOTTOM = 5

  LA_UP = 1
  LA_DOWN = 2

  OROOM = 0
  VAULT = 4

  STONE = 0
  VWALL = 1
  HWALL = 2
  TLCORNER = 3
  TRCORNER = 4
  BLCORNER = 5
  BRCORNER = 6
  DBWALL = 12
  SDOOR = 14
  SCORR = 15
  DOOR = 22
  CORR = 23
  ROOM = 24
  STAIRS = 25
  MAXNROFROOMS = 40
  COLNO = 80
  ROWNO = 21
  XLIM = 4
  YLIM = 3
  MAXRECT = 50
  attr_reader :rooms, :x_maze_max, :y_maze_max, :rect_cnt, :rect, :locations, :smeq, :nrooms, :doorindex, :doors

  def debug_print_rooms
    puts "-" * 80
    puts @rooms[0..@nrooms+2]
  end

  def initialize
    @doorindex = 0
    @doors = Array.new(DOORMAX) { Coord.init }
    @smeq = Array.new(MAXNROFROOMS, 0)
    @rooms = Array.new((MAXNROFROOMS + 1) * 2) { Room.init }
    @rooms[0].hx = -1
    @nrooms = 0
    @rect_cnt = 1
    @vault_x = nil
    @vault_y = nil
    @rect = Array.new(50) { Rect.init }
    @rect[0] = Rect.new(0, 0, COLNO-1, ROWNO-1)

    @locations = Array.new(COLNO) { Array.new(ROWNO) { Pos.init } }

    @x_maze_max = COLNO-1
    if @x_maze_max % 2 != 0
      @x_maze_max -= 1
    end

    @y_maze_max = ROWNO-1
    if @y_maze_max % 2 != 0
      @y_maze_max -= 1
    end
  end

  def print_rooms
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
        when SDOOR, DOOR then "+"
        when SCORR, CORR then "#"
        when STAIRS
          if col.flags == LA_UP
            "<"
          else
            ">"
          end
        else col.typ.to_s
        end
      end
      puts
    end
    nil
  end

  def generate
    makerooms
    tmprooms = @rooms[0...nrooms].sort { |a,b| a.lx <=> b.lx }
    @rooms[0...nrooms] = tmprooms
    croom = @rooms[rand(nrooms)]
    mkstairs(somex(croom), somey(croom), :down, croom)
    if nrooms > 1
      troom = croom
      croom = rooms[rand(nrooms - 1)]
      if croom == troom
        croom = rooms[rooms.index(croom) + 1]
      end
    end
    branchp = true
    room_threshold = branchp ? 4 : 3
    makecorridors
    print_rooms
  end

  private

  def makecorridors
    any = true
    0.upto(nrooms-1) do |a|
      join(a, a+1, false)
      break if rand(50) == 0
    end

    0.upto(nrooms-2) do |a|
      if smeq[a] != smeq[a+2]
        join(a, a+2, false)
      end
    end

    a = 0
    while any && a < nrooms
      any = false
      0.upto(nrooms) do |b|
        if smeq[a] != smeq[b]
          join(a, b, false)
          any = true
        end
      end
      a += 1
    end

    if nrooms > 2
      (rand(nrooms) + 4).downto(0) do |i|
        a = rand(nrooms)
        b = rand(nrooms - 2)
        if b >= a
          b += 2
        end

        join(a, b, true)
      end
    end
  end

  def join(a,b,nxcor)
    croom = rooms[a]
    troom = rooms[b]
    cc = Coord.init
    tt = Coord.init
    org = Coord.init
    dest = Coord.init

    if troom.hx < 0 || croom.hx < 0 || doorindex >= DOORMAX
      return
    end

    if troom.lx > croom.hx
      dx = 1
      dy = 0
      xx = croom.hx + 1
      tx = troom.lx - 1
      finddpos(cc, xx, croom.ly, xx, croom.hy)
      finddpos(tt, tx, troom.ly, tx, troom.hy)
    elsif troom.hy < croom.ly
      dy = -1
      dx = 0
      yy = croom.ly - 1
      finddpos(cc, croom.lx, yy, croom.hx, yy)
      ty = troom.hy + 1
      finddpos(tt, troom.lx, ty, troom.hx, ty)
    elsif troom.hx < croom.lx
      dx = -1
      dy = 0
      xx = croom.lx - 1
      tx = troom.hx + 1
      finddpos(cc, xx, croom.ly, xx, croom.hy)
      finddpos(tt, tx, croom.ly, tx, troom.hy)
    else
      dy = 1
      dx = 0
      yy = croom.hy + 1
      ty = troom.ly - 1
      finddpos(cc, croom.lx, yy, croom.hx, yy)
      finddpos(tt, troom.lx, ty, troom.hx, ty)
    end

    xx = cc.x
    yy = cc.y
    tx = tt.x - dx
    ty = tt.y - dy

    if nxcor && locations[xx+dx][yy+dy].typ != 0
      return
    end

    if okdoor(xx,yy) || !nxcor
      dodoor(xx, yy, croom)
    end

    org.x = xx + dx
    org.y = yy + dy
    dest.x = tx
    dest.y = ty

    if !dig_corridor(org, dest, nxcor, CORR, STONE)
      return
    end

    if okdoor(tt.x, tt.y) || !nxcor
      dodoor(tt.x, tt.y, troom)
    end

    if smeq[a] < smeq[b]
      smeq[b] = smeq[a]
    else
      smeq[a] = smeq[b]
    end
  end

  def dig_corridor(org, dest, nxcor, ftyp, btyp)
    dx = 0
    dy = 0
    xx = org.x
    yy = org.y
    tx = dest.x
    ty = dest.y

    if xx <= 0 || yy <= 0 || tx <= 0 || ty <= 0 || xx > COLNO - 1 || tx > COLNO - 1 || yy > ROWNO - 1 || ty > ROWNO - 1
      return false
    end

    if tx > xx
      dx = 1
    elsif ty > yy
      dy = 1
    elsif tx < xx
      dx = -1
    else
      dy = -1
    end

    xx -= dx
    yy -= dy
    cct = 0

    while xx != tx || yy != ty
      cct += 1
      if cct > 500 || (nxcor && rand(35) == 0)
        return false
      end

      xx += dx
      yy += dy

      if xx >= COLNO - 1 || xx <= 0 || yy <= 0 || yy >= ROWNO - 1
        return false
      end

      crm = locations[xx][yy]
      if crm.typ == btyp
        if ftyp != CORR || rand(100) != 0
          crm.typ = ftyp
          if nxcor && rand(50) == 0
            # BOULDER
          end
        else
          crm.typ = SCORR
        end
      else
        if crm.typ != ftyp && crm.typ != SCORR
          # strange
          return false
        end
      end

      dix = (xx-tx).abs
      diy = (yy-ty).abs

      if dy != 0 && dix > diy
        ddx = (xx > tx) ? -1 : 1
        crm = locations[xx+ddx][yy]
        if crm.typ == btyp || crm.typ == ftyp || crm.typ == SCORR
          dx = ddx
          dy = 0
          next
        end
      elsif dx != 0 && diy > dix
        ddy = (yy > ty) ? -1 : 1
        crm = locations[xx][yy+ddy]
        if crm.typ == btyp || crm.typ == ftyp || crm.typ == SCORR
          dy = ddy
          dx = 0
          next
        end
      end

      crm = locations[xx+dx][yy+dy]
      if crm.typ == btyp || crm.typ == ftyp || crm.typ == SCORR
        next
      end

      if dx != 0
        dx = 0
        dy = (ty < yy) ? -1 : 1
      else
        dy = 0
        dx = (tx < xx) ? -1 : 1
      end

      crm = locations[xx+dx][yy+dy]
      if crm.typ == btyp || crm.typ == ftyp || crm.typ == SCORR
        next
      end

      dy = -dy
      dx = -dx
    end

    true
  end

  def bydoor(x, y)
    typ = nil
    if isok(x+1, y)
      typ = locations[x+1][y].typ
      if is_door(typ) || typ == SDOOR
        return true
      end
    end

    if isok(x-1, y)
      typ = locations[x-1][y].typ
      if is_door(typ) || typ == SDOOR
        return true
      end
    end

    if isok(x, y+1)
      typ = locations[x][y+1].typ
      if is_door(typ) || typ == SDOOR
        return true
      end
    end

    if isok(x, y-1)
      typ = locations[x][y-1]
      if is_door(typ) || typ == SDOOR
        return true
      end
    end

    false
  end

  def isok(x, y)
    x >= 1 && x <= COLNO - 1 && y >= 0 && y <= ROWNO - 1
  end

  def is_door(typ)
    typ == DOOR
  end

  def okdoor(x, y)
    near_door = bydoor(x, y)
    (locations[x][y].typ == HWALL || locations[x][y].typ == VWALL) &&
      doorindex < DOORMAX && !near_door
  end

  def finddpos(cc, xl, yl, xh, yh)
    x = (xl == xh) ? xl : (xl + rand(xh - xl + 1))
    y = (yl == yh) ? yl : (yl + rand(yh - yl + 1))

    gotit = false

    if okdoor(x, y)
      gotit = true
    end

    unless gotit
      xl.upto(xh) do |x|
        yl.upto(yh) do |y|
          if okdoor(x, y)
            gotit = true
            break
          end
        end
        break if gotit
      end
    end

    unless gotit
      xl.upto(xh) do |x|
        yl.upto(yh) do |y|
          if is_door(locations[x][y].typ) || locations[x][y].typ == SDOOR
            gotit = true
            break
          end
        end
        break if gotit
      end
    end

    unless gotit
      x = xl
      y = yh
    end

    # gotit
    cc.x = x
    cc.y = y
  end

  def mkstairs(x, y, dir, room)
    @locations[x][y].typ = STAIRS
    @locations[x][y].flags = dir == :up ? LA_UP : LA_DOWN
  end

  def somex(room)
    rand(room.hx - room.lx + 1) + room.lx
  end

  def somey(room)
    rand(room.hy - room.ly + 1) + room.ly
  end

  def create_vault
    create_room(-1, -1, 2, 2, -1, 1, VAULT, true)
  end

  def makerooms
    tried_vault = false

    while (nrooms < MAXNROFROOMS) && rnd_rect
      if(nrooms >= (MAXNROFROOMS/6) && rand(2) != 0 && !tried_vault)
        tried_vault = true
        if create_vault
          @vault_x = rooms[nrooms].lx
          @vault_y = rooms[nrooms].ly
          rooms[nrooms].hx = -1
        end
      else
        return unless create_room(-1, -1, -1, -1, -1, -1, OROOM, -1)
      end
    end
  end

  def create_room(x, y, w, h, xal, yal, rtype, rlit)
    xabs = nil
    yabs = nil
    wtmp = nil
    htmp = nil

    r1 = rnd_rect
    r2 = Rect.init

    trycnt = 0
    vault = false

    xlim = XLIM
    ylim = YLIM

    if rtype == -1
      rtype = OROOM
    end

    if rtype == VAULT
      vault = true
      xlim += 1
      ylim += 1
    end

    if rlit == -1
      rlit = rand(1 + 1) < 11 && rand(77) != 0
    end

    loop do
      wtmp = w
      htmp = h
      xtmp = x
      ytmp = y
      xaltmp = xal
      yaltmp = yal

      if (xtmp < 0 && ytmp < 0 && wtmp < 0 && xaltmp < 0 && yaltmp < 0) || vault
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

        if (hx-lx < (dx + 3 + xborder)) || (hy-ly < (dy + 3 + yborder))
          r1 = nil
          trycnt += 1
          break if trycnt > 100 || r1
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
          trycnt += 1
          break if trycnt > 100 || r1
          next
        end

        wtmp = dx+1
        htmp = dy+1

        r2.lx = xabs - 1
        r2.ly = yabs - 1
        r2.hx = xabs + wtmp
        r2.hy = yabs + htmp
      else
        rndpos = 0
        if xtmp < 0 && ytmp < 0
          xtmp = rand(5)
          ytmp = rand(5)
          rndpos = 1
        end

        if wtmp < 0 || htmp < 0
          wtmp = rand(15) + 3
          htmp = rand(8) + 2
        end

        if xaltmp == -1
          xaltmp = rand(3)
        end

        if yaltmp == -1
          yaltmp = rand(3)
        end

        xabs = (((xtmp - 1) * COLNO) / 5) + 1
        yabs = (((ytmp - 1) * ROWNO) / 5) + 1

        case xaltmp
        when LEFT then nil
        when RIGHT then xabs += (COLNO / 5) - wtmp
        when CENTER then xabs += ((COLNO / 5) - wtmp) / 2
        end

        case yaltmp
        when TOP then nil
        when BOTTOM then yabs += (ROWNO / 5) - htmp
        when CENTER then yabs += ((ROWNO / 5) - htmp) / 2
        end

        if xabs + wtmp -1 > COLNO - 2
          xabs = COLNO - wtmp - 3
        end

        if xabs < 2
          xabs = 2
        end

        if yabs + htmp - 1 > ROWNO - 2
          yabs = ROWNO - htmp - 3
        end

        if yabs < 2
          yabs = 2
        end

        r2.lx = xabs - 1
        r2.ly = yabs - 1
        r2.hx = xabs + wtmp + rndpos
        r2.hy = yabs + htmp + rndpos
        r1 = get_rect(r2)
      end

      trycnt += 1
      break if trycnt > 100 || r1
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

    croom = rooms[rooms.index(croom) + 1]
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
      index = [lowy-1, 0].max
      (lowy-1).upto(hiy+1) do |y|
        lev = locations[x][index]
        lev.lit = true
        index += 1
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
    old_r = r1.dup
    remove_rect(r1)

    (rect_cnt-1).downto(0) do |i|
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

    end

    ddx = hix - lowx
    ddy = hiy - lowy

    [true, lowx, ddx, lowy, ddy, vault]
  end

  def is_wall(typ)
    typ != 0 && typ <= DBWALL
  end

  def dodoor(x, y, aroom)
    if doorindex >= DOORMAX
      return
    end

    dosdoor(x, y, aroom, rand(8) == 0 ? DOOR : SDOOR)
  end

  def dosdoor(x, y, aroom, type)
    # shdoor = in_rooms(x, y, SHOPBASE)
    shdoor = false

    if !is_wall(locations[x][y].typ)
      type = DOOR
    end

    locations[x][y].typ = type

    if type == DOOR
      if rand(3) == 0
        if rand(5) == 0
          locations[x][y].flags = D_ISOPEN
        elsif rand(6) == 0
          locations[x][y].flags = D_LOCKED
        else
          locations[x][y].flags = D_CLOSED
        end

        # if locations[x][y].flags != D_ISOPEN && !shdoor && level_difficulty >= 5 && rand(25) == 0
        #   locations[x][y[.flags |= D_TRAPPED
        # else
        locations[x][y].flags = shdoor ? D_ISOPEN : D_NODOOR
        # end

        # mimic
      end
    else # SDOOR
      if(shdoor || rand(5) == 0)
        locations[x][y].flags = D_LOCKED
      else
        locations[x][y].flags = D_CLOSED
      end
    end

    # if !shdoor && level_difficulty >= 4 && rand(20) == 0
    #   locations[x][y].flags |= D_TRAPPED
    # end

    add_door(x, y, aroom)
  end

  def add_door(x, y, aroom)
    tmp = nil
    aroom.doorct += 1
    broom = rooms[rooms.index(aroom)+1]
    if broom.hx < 0
      tmp = doorindex
    else
      tmp = doorindex
      doorindex.downto(broom.fdoor + 1) do |a|
        tmp = a
        doors[tmp] = doors[tmp-1]
      end
    end

    @doorindex += 1
    doors[tmp].x = x
    doors[tmp].y = y

    while broom.hx >= 0
      broom.fdoor += 1
      broom = rooms[rooms.index(broom) + 1]
    end
  end

  def rnd_rect
    if rect_cnt > 0
      rect[rand(rect_cnt)]
    end
  end
end

seed = ENV["SEED"] || Random::DEFAULT.seed
srand(seed.to_i)
puts "SEED: #{seed}"
Dungeon.new.generate

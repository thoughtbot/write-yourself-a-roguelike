## Chapter 8 - Generating random rooms

Here `xlim` and `ylim` represent the amount of horizontal and vertical space we want around our room. The conditional specified in each check is to verify that the rectangle we're placing our new rectangle into does not take up the entire width or height of our screen. If it doesn't take up the full width or height we multiply `xlim` or `ylim` by 2 respectively. This value is the "padding" on for both sides. If we are placing it into a rectangle that takes up the full width or height, then we know if can't possibly be next to another rectangle in that dimension and therefor we just want to offset it a little from the corresponding side.

After we've determined our width, height, xborder, and yborder we'll want to figure out where in the current rectangle we're going to put this new rectangle:

```ruby
xabs = rect.left +
  (rect.left > 0 ? xlim : 3) +
  rand(rect.right - (rect.left > 0 ? rect.left : 3) - dx - xborder + 1)

yabs = rect.top +
  (rect.top > 0 ? ylim: 2) +
  rand(rect.bottom - (rect.top > 0 ? rect.top : 2) - dy - yborder + 1)
```

There's quite a bit to decipher here so let's break it down. To find an x position we'll first start from the left side of our containing rectangle, we then inset our rectangle just a little (we don't want two rectangles to end up directly next to each other). Next we add a random amount, but we want to make sure we have enough room so we don't want to generate a number that would cause our rectangle to be outside of our containing rectangle. To ensure we don't run into this situation we take the right side and subtract either the left (if not zero) or 3 (for an inset). Then we substract the width and xborder and then add 1 since `0 <= rand(x) < x`.

Once we've determined the `xabs`,`yabs`, `dx` and `dy` we have a rectangle. Let's draw our rectanle on the screen. We can do this in 3 steps, first we'll draw the horizontal walls. Here we'll draw the entire top row and bottom row of our room with `-`:

```ruby
[top - 1, bottom + 1].each do |y|
  (left - 1).upto(right + 1) do |x|
    dungeon[y][x] = HWALL
  end
end
```

For the vertical walls we'll do something similar, but we'll use `|`s for the left and right walls:

```ruby
top.upto(bottom) do |y|
  [left - 1, right + 1].each do |x|
    dungeon[y][x] = VWALL
  end
end
```

Finally we'll draw in the floor with `.`s:

```ruby
top.upto(bottom) do |y|
  left.upto(right) do |x|
    dungeon[y][x] = FLOOR
  end
end
```

Now we can start printing our random rooms to the screen. Here is a full listing of the code used for generating and drawing a single random room:

```ruby
class Rect < Struct.new(:left, :top, :right, :bottom); end

class Dungeon
  COLNO = 80
  ROWNO = 21

  STONE = " "
  HWALL = "-"
  VWALL = "|"
  FLOOR = "."

  def initialize
    @dungeon = Array.new(ROWNO) { Array.new(COLNO) { STONE } }
    @rects = [ Rect.new(0, 0, COLNO - 1, ROWNO - 1) ]
  end

  def generate
    make_rooms
    print_dungeon
  end

  private

  attr_reader :dungeon, :rects

  def print_dungeon
    puts dungeon.map(&:join)
  end

  def make_rooms
    create_room
  end

  def create_room
    xlim = 4
    ylim = 3

    rect = rects.sample

    dx = 2 + rand((rect.right - rect.left > 8) ? 12 : 8)
    dy = 2 + rand(4)

    xborder = (rect.left > 0 && rect.right < COLNO - 1) ? 2 * xlim : xlim + 1
    yborder = (rect.top > 0 && rect.bottom < ROWNO - 1) ? 2 * ylim : ylim + 1

    xabs = rect.left +
      (rect.left > 0 ? xlim : 3) +
      rand(rect.right - (rect.left > 0 ? rect.left : 3) - dx - xborder + 1)

    yabs = rect.top +
      (rect.top > 0 ? ylim : 2) +
      rand(rect.top - (rect.bottom > 0 ? rect.top : 2) - dy - yborder + 1)

    add_room(xabs, yabs, xabs + dx, yabs + dy)
  end

  def add_room(left, top, right, bottom)
    [top - 1, bottom + 1].each do |y|
      (left - 1).upto(right + 1) do |x|
        dungeon[y][x] = HWALL
      end
    end

    top.upto(bottom) do |y|
      [left - 1, right + 1].each do |x|
        dungeon[y][x] = VWALL
      end

      left.upto(right) do |x|
        dungeon[y][x] = FLOOR
      end
    end
  end
end

Dungeon.new.generate
```

Now that we've generated a single room we're going to want to generate more of course. The gist of how we'll do this is by splitting our dungeon into new rectangles when we've placed a room. First we'll start with a list with a single rectangle (the entire dungeon) in it. We randomly select a rectangle and then generate a random room to fit into it. We then split that rectangle into 4 more rectangles that will surround our room. We'll discard any rectangles that are too small to fit a room into and then put the sub rectangles back into the list. We're done adding rooms when either the list is empty or we've added a maximum number of rooms. This process is easier to understand once visualized:

\includegraphics[width=\linewidth]{images/room_generation.png}

So now, well change our code so that before we call `add_room` we'll split our rect and discard the unusable rectangles that result. Then we can keep calling `create_room` while there are still rectangles available. Eventually we'll either have created a maximum number of rooms (fairly unlikely) or we'll have run out of area big enough to add more rooms. Let's make the following changes:

```ruby
class Room < Rect; end
```

```ruby
class Dungeon
  # ...

  # Add this to the top
  MAX_NUMBER_OF_ROOMS = 40

  # ...

  def initialize
    # ...
    @rooms = []
  end

  # ...

  # modify the existing makerooms function
  def makerooms
    while (rooms.count < MAX_NUMBER_OF_ROOMS) && rects.any?
      return unless create_room
    end
  end

  def create_room
    # ...

    room = Room.new(xabs, yabs, xabs+wtmp-1, yabs+htmp-1)
    rooms << room

    true
  end

  # ...
end
```

If you run this now you'll get something like:

```
            ----------- -------                                    ------
        ---------------------------------------          -------  --------
       --------......|.....|-----------.......|----------------|--|......|
       |......|......|--------........|.......|------|........||----------
       |......|......||......|........|.......|..----|........|||........|
     --|......|-.....||......|...--------------..|...|........|||........|
     |.|......||.....||......|---|..........|....|...|........|||........|
     |.--------|.....||......|...|..........|....|...|........|-----------
     |.........|--------------...|..........|....----|........|----|....|
     |.........|....|............|..........|........----------   ||....|
     |.........|....|............----------------------|.....|    ||....|
     -----------....----------------         |........||.....|    -------
               ----------|...|               ----------|.....|
                         -----                         -------
```

Now we need to implement our split_rects function:

```ruby
# add this as a private method
def split_rects(r1, r2)
  rects.delete(r1)

  # if any of the rectangles intersect let's delete them and add new ones
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
```

It's very easy to tell if two rectangles overlap using axis-aligned bounding boxes or AABBs. AABBs see frequent usage in shoot-em up games, due to the simplicity of the equation involved. Basically, in order to check if two triangles overlap you have to make the following 4 checks:

1. The top of triangle A is higher than the bottom of triangle B
2. The bottom of triangle A is lower than the top of triangle B
3. The left side of triangle A is to the left side of the right side of triangle B
4. The right side of triangle A is to the right side of the left side of triangle B

\includegraphics[width=\linewidth]{images/aabbs.png}

Our `intersect?` function will need to check if they intersect and then return the intersection

```ruby
def intersects?(rect)
  top > rect.bottom &&
    bottom < rect.top &&
    left < rect.right &&
    right > rect.left
end
```

So as you can see it simply checks the 4 conditions we've specified using `>` and `<`. Now that we know how to check if two rectangles overlap, let's discuss how we'll apply this. A fairly naive program would generate a random rectangle and if it didn't intersect any other rectangles we'd place it in the room. Rinse and repeat for the desired number of rooms.

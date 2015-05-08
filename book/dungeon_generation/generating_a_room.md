## Chapter 8 - Generating a Room

Rooms in nethack are all rectangular with `.` representing the floor and walls represented by `|` and `-`. We're going to start generating our dungeon by creating a single room. To generate this room we need to follow a few guidelines. We want this room to fit entirely within our dungeon and we don't want it to be too big or too small. For instance, the minimum size of a room should be 2x2.

We'll want our y direction to be more constrained than our x due to the nature of characters taking up more vertical space than horizontal. In our case our dungeon will be 80 character wide by 20 characters tall. So let's set a maximum y value of 6. We can represent this with:

```ruby
height = 2 + rand(4)
```

For our x direction let's start with a minimum of 2 and a maximum of 14:

```ruby
width = 2 + rand(12)
```

We'll want to set one more constaint here. Let's ensure that the area of a room is never greater than 50. We'll do this by decreasing the height if our room is too big:

```ruby
if width * height > 50
  width = 50 / height
end
```

Now in order to place our room, let's assume that we're trying to fit it into a rectangle. We'll start with a rectangle the size of our dungeon.

```ruby
class Rect < Struct.new(:left, :top, :right, :bottom)
end

rect = Rect.new(0, 0, 80, 21)
```

Now in order to fit our room into this rectangle the left position of our room must be at least one more than the left of the rectangle (in order to have room for the left wall). From that position we want to add some number between 0 and (width + 3) less than the right side (2 for the walls and 1 for our initial offset). Since rand(n) already gives a range of 0 to n - 1 we simply need to take the rectangle's right hand value and subtract with width and 2 (not 3 since rand already subtracts 1 for us):

```ruby
left = rect.left + 1 + rand(rect.right - width - 2)
```

For the top value, we do the same thing:

```ruby
top = rect.top + 1 + rand(rect.bottom - height - 2)
```

Now we can calculate the `right` and `bottom` values of our room:

```ruby
right = left + width
bottom = top + height
```

Now that we have our rooms coordinates we'll want to draw this rectangle in our "dungeon." Let's start by initializing our dungeon with stone. We'll represent stone with a space " ":

```ruby
dungeon = Array.new(21) { Array.new(80) { " " } }
```

Now let's draw the floor of our room:

```ruby
left.upto(right) do |x|
  top.upto(bottom) do |y|
    dungeon[y][x] = "."
  end
end
```

To draw the vertical walls we'll do the following:

```ruby
top.upto(bottom) do |y|
  dungeon[y][left - 1] = "|"
  dungeon[y][right + 1] = "|"
end
```

For the horizontal walls:

```ruby
(left - 1).upto(right + 1) do |x|
  dungeon[top - 1][x] = "-"
  dungeon[bottom + 1][x] = "-"
end
```

Finally, let's print the dungeon and look at the output:

```ruby
puts dungeon.map(&:join)
```

```
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                ---------                                       
                                |.......|                                       
                                |.......|                                       
                                |.......|                                       
                                ---------                                       
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
```

Let's convert this code into a class:

```ruby
class Rect < Struct.new(:left, :top, :right, :bottom)
end

class Dungeon
  WIDTH = 80
  HEIGHT = 21

  STONE = " "
  FLOOR = "."
  HWALL = "-"
  VWALL = "|"

  def initialize
    @dungeon = Array.new(HEIGHT) { Array.new(WIDTH) { STONE } }
    @rects = [ Rect.new(0, 0, WIDTH, HEIGHT) ]
  end

  def generate
    room = create_room
    draw_room(room)
    draw_dungeon
  end

  private

  attr_reader :dungeon, :rects

  def create_room
    rect = rects.first

    height = 2 + rand(4)
    width = 2 + rand(12)

    if width * height > 50
      width = 50 / height
    end

    left = rect.left + 1 + rand(rect.right - width - 2)
    top = rect.top + 1 + rand(rect.bottom - height - 2)

    right = left + width
    bottom = top + height

    Rect.new(left, top, right, bottom)
  end

  def draw_dungeon
    puts dungeon.map(&:join)
  end

  def draw_room(room)
    draw_floor(room)
    draw_vertical_walls(room)
    draw_horizontal_walls(room)
  end

  def draw_floor(room)
    room.left.upto(room.right) do |x|
      room.top.upto(room.bottom) do |y|
        dungeon[y][x] = "."
      end
    end
  end

  def draw_vertical_walls(room)
    room.top.upto(room.bottom) do |y|
      dungeon[y][room.left - 1] = "|"
      dungeon[y][room.right + 1] = "|"
    end
  end

  def draw_horizontal_walls(room)
    (room.left - 1).upto(room.right + 1) do |x|
      dungeon[room.top - 1][x] = "-"
      dungeon[room.bottom + 1][x] = "-"
    end
  end
end

dungeon = Dungeon.new.generate
```

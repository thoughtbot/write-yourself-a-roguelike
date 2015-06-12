## Chapter 8 - Generating a Room

Rooms in nethack are all rectangular with `.` representing the floor and walls represented by `|` and `-`. We're going to start generating our dungeon by creating a single random room. To generate this room we need to follow a few guidelines. We want this room to fit entirely within our dungeon and we don't want it to be too big or too small. For instance, the minimum size of a room should be 2x2.

We'll want our y direction to be more constrained than our x due to the nature of characters taking up more vertical space than horizontal. In our case our dungeon will be 80 character wide by 20 characters tall. So let's set a maximum y value of 6. Add the following to a file named `dungeon_generator.rb`:

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
Rect = Struct.new(:left, :top, :right, :bottom)

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

Now let's draw the floor of our room. To do this, we'll just use a nested loop going from left to right and then top to bottom:

```ruby
left.upto(right) do |x|
  top.upto(bottom) do |y|
    dungeon[y][x] = "."
  end
end
```

Now let's see what our dungeon looks like:

```ruby
puts dungeon.map(&:join)
```

```











                                     ...........
                                     ...........
                                     ...........
                                     ...........
                                     ...........
                                     ...........




```

To draw the vertical walls we'll want to iterate from top to bottom adding a wall one space to the left of our room and a wall one space to the right of our room:

```ruby
top.upto(bottom) do |y|
  dungeon[y][left - 1] = "|"
  dungeon[y][right + 1] = "|"
end
```

For the horizontal walls we'll do something similar:

```ruby
(left - 1).upto(right + 1) do |x|
  dungeon[top - 1][x] = "-"
  dungeon[bottom + 1][x] = "-"
end
```

Now let's print our dungeon again, but this time we'll see walls:

```








                                ---------
                                |.......|
                                |.......|
                                |.......|
                                ---------








```

Now that we have an idea of how to generate our random rooms, let's be more object-oriented with our code and convert this code into a objects:

```ruby
Rect = Struct.new(:left, :top, :right, :bottom)

class DungeonGenerator
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
    render_room(room)
    print_dungeon
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

  def print_dungeon
    puts dungeon.map(&:join)
  end

  def render_room(room)
    render_floor(room)
    render_vertical_walls(room)
    render_horizontal_walls(room)
  end

  def render_floor(room)
    room.left.upto(room.right) do |x|
      room.top.upto(room.bottom) do |y|
        dungeon[y][x] = "."
      end
    end
  end

  def render_vertical_walls(room)
    room.top.upto(room.bottom) do |y|
      dungeon[y][room.left - 1] = "|"
      dungeon[y][room.right + 1] = "|"
    end
  end

  def render_horizontal_walls(room)
    (room.left - 1).upto(room.right + 1) do |x|
      dungeon[room.top - 1][x] = "-"
      dungeon[room.bottom + 1][x] = "-"
    end
  end
end

dungeon_generator = DungeonGenerator.new
dungeon_generator.generate
```

While this code is decent there still an opportunity to refactor it a bit further by reducing the responsibilities of our dungeon class. Currently it knows how to create rooms and render itself. We can pull out the creation of rooms into its own class like so:

```ruby
class RoomGenerator
  def initialize(rect)
    @rect = rect
    @room = Rect.new(0, 0, 0, 0)
  end

  def generate
    width, height = get_dimensions
    left, top = get_position_by_dimensions(width, height)
    right = left + width
    bottom = top + height

    Rect.new(left, top, right, bottom)
  end

  private

  attr_reader :room, :rect

  def get_dimensions
    height = get_height
    width = get_width_bound_by_height(height)

    [width, height]
  end

  def get_height
    2 + rand(4)
  end

  def get_width_bound_by_height(height)
    width = 2 + rand(12)

    if width * height > 50
      width = 50 / height
    end

    width
  end

  def get_position_by_dimensions(width, height)
    left = rect.left + 1 + rand(rect.right - width - 2)
    top = rect.top + 1 + rand(rect.bottom - height - 2)

    [left, top]
  end
end
```

Then we can change the `create_room` function of our `DungeonGenerator` to utilize this like so:

```ruby
def create_room
  rect = rects.first
  room_generator = RoomGenerator.new(rect)
  room_generator.generate
end
```

If we wanted to, we could easily rewrite our dungeon class to be initialized with options in order to change which room generator gets used, but since we only have one for now we'll leave it alone and let our code evolve naturally before we try to refactor.

At this point we have a great foundation for progressing our dungeon generator. Moving forward, we'll need to add more rooms, dig corridors, and add doors.

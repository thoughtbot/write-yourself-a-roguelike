## Chapter 8 - Generating a Room

Rooms in NetHack are all rectangular with `.` representing the floor and walls represented by `|` or `-`.


```

----
|..|
|..|
----

the smallest possible room

```


Each room is randomly assigned a width and a height and then possibly added to the dungeon. Due to randomness, sometimes the room won't fit in the given dungeon and therefore it is discarded. This is but a single step in the process of generating a dungeon.

We're going to start our dungeon generation process by creating a single random room. To generate this room we'll need to follow a few guidelines. We'll want this room to fit entirely within our dungeon and we won't want it to be too big or too small. For instance, the minimum size of a room should be 2x2.

We'll also want our height to be more constrained than our width due to the nature of characters in a terminal taking up more vertical space than horizontal. In our case, our dungeon will be 80 characters wide by 20 characters tall. Let's start by generating a height between 2 and 6. Add the following to a file named `dungeon_generator.rb`:

```ruby
height = 2 + rand(4)
```

For our width, let's generate a value between 2 and 14:

```ruby
width = 2 + rand(12)
```

In order to prevent rooms, that are too big, we'll want to set one more constraint here. Let's ensure that the area of a room is never greater than 50. We'll do this by decreasing the width if our room is too big:

```ruby
if width * height > 50
  width = 50 / height
end
```

Now in order to place our room, let's assume that we're trying to fit it into a rectangular subsection of our dungeon. At the moment that subsection is exactly the same size as our dungeon. Later when we add more rooms, we'll create smaller subsections. Here is a `Rect` class and instance to represent that subsection:

```ruby
Rect = Struct.new(:left, :top, :right, :bottom)

rect = Rect.new(0, 0, 80, 21)
```

Now in order to fit our room into this rectangle the left side of our room must be at least one more character to the right than the left side of our subsection. This is necessary in order to have room for the left wall. In order to randomly place the room inside our subsection, we'll want to find a suitable position for the left side of our room. The total space needed for our room is it's width plus 2 (for both walls). If we went with the equation `left = rect.left + rand(rect.right - width - 2)` we'd run into a problem because rand will generate a value between 0 and n. If it were to generate 0 then we would not have room for our wall, so the equation we actually need is:

```ruby
left = rect.left + 1 + rand(rect.right - width - 2)
```

For the top value, we'll do the same thing:

```ruby
top = rect.top + 1 + rand(rect.bottom - height - 2)
```

Now we can calculate the `right` and `bottom` values of our room:

```ruby
right = left + width
bottom = top + height
```

With those room coordinates, we'll want to draw this rectangle in our "dungeon." Let's start by initializing our dungeon with stone. We'll represent stone with a space character:

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

Because our room should be random it will be located in a new spot with different dimensions. Now that we have an idea of how to generate our random rooms, let's be more object-oriented with our code and start converting this code into objects:

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

  def render_room(room)
    render_floor(room)
    render_vertical_walls(room)
    render_horizontal_walls(room)
  end

  def render_floor(room)
    room.left.upto(room.right) do |x|
      room.top.upto(room.bottom) do |y|
        dungeon[y][x] = FLOOR
      end
    end
  end

  def render_vertical_walls(room)
    room.top.upto(room.bottom) do |y|
      dungeon[y][room.left - 1] = VWALL
      dungeon[y][room.right + 1] = VWALL
    end
  end

  def render_horizontal_walls(room)
    (room.left - 1).upto(room.right + 1) do |x|
      dungeon[room.top - 1][x] = HWALL
      dungeon[room.bottom + 1][x] = HWALL
    end
  end

  def print_dungeon
    puts dungeon.map(&:join)
  end
end

dungeon_generator = DungeonGenerator.new
dungeon_generator.generate
```

While this code is decent, there still an opportunity to refactor it a bit further by reducing the responsibilities of our `DungeonGenerator`. Currently it knows how to create rooms and render a dungeon. Since games often have a tendency to quickly get out of control we'll want to follow the Single Responsibility Principle as closely as we can. Let's pull out a few classes with single responsibilities. For starters, let's make a class that can generate rooms

```ruby
class RoomGenerator
  MIN_WIDTH = 2
  MIN_HEIGHT = 2
  MAX_WIDTH_MODIFIER = 12
  MAX_HEIGHT_MODIFIER = 4
  MAX_FLOOR_AREA = 50

  def initialize(rect)
    @rect = rect
  end

  def generate
    constrain_floor_area
    build_room
  end

  private

  attr_reader :rect

  def constrain_floor_area
    if floor_area > MAX_FLOOR_AREA
      @width = 50 / height
    end
  end

  def build_room
    Rect.new(left, top, right, bottom)
  end

  def floor_area
    width * height
  end

  def height
    @height ||= MIN_HEIGHT + rand(MAX_HEIGHT_MODIFIER)
  end

  def width
    @width ||= MIN_WIDTH + rand(MAX_WIDTH_MODIFIER)
  end

  def left
    @left ||= rect.left + 1 + rand(rect.right - width - 2)
  end

  def top
    @top ||= rect.top + 1 + rand(rect.bottom - height - 2)
  end

  def right
    @right ||= left + width
  end

  def bottom
    @bottom ||= top + height
  end
end
```

The great part about the class we've extracted is that we now have a great place for storing the relevant constants without polluting our `DungeonGenerator` class. We can also easily extract fairly short methods that all deal with the concept of generating a room. Had we have done this inside our `DungeonGenerator` class it would be a rather messy and confusing class.

Since we could possibly want to change the way we generate rooms in a dungeon, let's use dependency injection to allow us to change the generator. While we're at it, let's make width and height options you can pass in. First rename the constants `WIDTH` and `HEIGHT` from our `DungeonGenerator` to `DEFAULT_WIDTH` and `DEFAULT_HEIGHT` and then modify its `initialize` method to take in `options`:

```ruby
def initialize(options = {})
  @options = options
  @dungeon = Array.new(height) { Array.new(width) { STONE }
  @rects = [ Rect.new(0, 0, width, height) ]
end
```

Then we can change the `create_room` function of our `DungeonGenerator` to utilize this like so:

```ruby
def create_room
  RoomGenerator.new(rects.first).generate
end
```

Similarly, we'll add methods for `width` and `height`:

```ruby
def width
  options.fetch(:width, DEFAULT_WIDTH)
end

def height
  options.fetch(:height, DEFAULT_HEIGHT)
end
```

You'll also need to make sure to add `:options` to our `attr_reader`s:

```ruby
attr_reader :dungeon, :rects, :options
```

Another class we can now pull out is `Dungeon` itself. It seems odd that the `DungeonGenerator` knows what to render for stone, floors, and walls. In order to do this, let's first extract a `Tileset` class:

```ruby
require_relative "data_loader"

class Tileset
  def self.load(name, loader: DataLoader)
    data = loader.load_file("tilesets/#{name}")
    new(data)
  end

  def initialize(tiles)
    @tiles = tiles
  end

  def [](key)
    tiles[key]
  end

  private

  attr_reader :tiles
end
```

Then we'll need our "default" tileset. Create the file `data/tilesets/default.yaml` with:

```yaml
---
stone: " "
floor: "."
vertical_wall: "|"
horizontal_wall: "-"
```

Now that we have a way of loading our tilesets, let's create our `Dungeon` class:


```ruby
class Dungeon
  attr_reader :rows

  def initialize(width, height, tileset:)
    @tileset = tileset
    @rows = Array.new(height) { Array.new(width) { tileset[:stone] } }
  end

  def build(type, x, y)
    rows[y][x] = tileset[type]
  end

  private

  attr_reader :tileset
end
```

We'll also need to update `DungeonGenerator` to load and pass along our tileset. Change the `initialize` method to:

```ruby
def initialize(options = {})
  @options = options
  @dungeon = Dungeon.new(width, height, tileset: tileset)
  @rects = [ Rect.new(0, 0, width, height) ]
end
```

Then add the following `private` methods:

```ruby
def tileset
  @_tileset ||= Tileset.load(tileset_name)
end

def tileset_name
  options.fetch(:tileset_name, DEFAULT_TILESET_NAME)
end
```

Then add the contant `DEFAULT_TILESET_NAME` to `DungeonGenerator`:

```ruby
DEFAULT_TILESET_NAME = "default"
```

Now that the tileset is handling the characters of our dungeon, let's remove the constants `STONE`, `FLOOR`, `HWALL`, and `VWALL` from `DungeonGenerator`.

Next let's remove the methods used for rendering a room from our `DungeonGenerator` and extract it into a `RoomRenderer` class. To do this you'll want to remove `render_floor`, `render_vertical_walls`, and `render_horizontal_walls`. Then create the following `RoomRenderer` class:

```ruby
class RoomRenderer
  def initialize(room, dungeon)
    @left = room.left
    @right = room.right
    @top = room.top
    @bottom = room.bottom
    @dungeon = dungeon
  end

  def render
    render_floor
    render_vertical_walls
    render_horizontal_walls
  end

  private

  attr_reader :top, :left, :right, :bottom, :dungeon

  def render_floor
    left.upto(right) do |x|
      top.upto(bottom) do |y|
        dungeon.build(:floor, x, y)
      end
    end
  end

  def render_vertical_walls
    top.upto(bottom) do |y|
      dungeon.build(:vertical_wall, left - 1, y)
      dungeon.build(:vertical_wall, right + 1, y)
    end
  end

  def render_horizontal_walls
    (left - 1).upto(right + 1) do |x|
      dungeon.build(:horizontal_wall, x, top - 1)
      dungeon.build(:horizontal_wall, x, bottom + 1)
    end
  end
end
```

Now that we have a separate class for rendering our room, we can have our `DungeonGenerator` utilize it by replacing `render_room` like so:

```ruby
def render_room(room)
  room_renderer.new(room, dungeon).render
end

def room_renderer
  options.fetch(:room_renderer, RoomRenderer)
end
```

To be consistent, let's pull out a `DungeonPrinter` class that will print our dungeon. To make this work, we'll delete `DungeonGenerator#print_dungeon` and change the `DungeonGenerator#generate` method to look like:

```ruby
def generate
  room = create_room
  render_room(room)
  dungeon
end
```

and add the following `DungeonPrinter` class:

```ruby
class DungeonPrinter
  def initialize(dungeon, io = STDOUT)
    @dungeon = dungeon
    @io = io
  end

  def print
    io.puts dungeon.rows.map(&:join)
  end

  private

  attr_reader :io, :dungeon
end
```

Finally, let's change:

```ruby
dungeon_generator = DungeonGenerator.new
dungeon_generator.generate
```

to:

```ruby
dungeon = DungeonGenerator.new.generate
DungeonPrinter.new(dungeon).print
```

If you haven't done so already, I'd suggest separating each class into it's own file to make editing the project easier.

At this point, we're doing a fairly good job of adhering to the Single Responsibility Principle and it should make evolving our code go a lot more smoothly than if we hadn't. We have a lot ahead of us in order to get our DungeonGenerator to where we want. Next, we'll be tackling one of the hardest parts of generating our dungeon - adding more rooms.

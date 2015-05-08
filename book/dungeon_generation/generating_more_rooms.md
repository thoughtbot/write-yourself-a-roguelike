## Chapter 9 - Generating More Rooms

Now that we've generated a single room we'll want to start generating more. Let's start simple with a few modifications to our existing class. First let's add a constant that represents the maximum number of rooms we can have:

```ruby
MAX_NUMBER_OF_ROOMS = 40
```

In our initializer we'll create an array to store all the rooms we've made:

```ruby
@rooms = []
```

Let's also add `rooms` to our existing attr_readers:

```ruby
attr_reader :dungeon, :rects, :rooms
```

Let's also break up our `generate` method into the following:

```ruby
def generate
  make_rooms
  draw_rooms
  draw_dungeon
end
```

In order to implement make_rooms, we'll start with simply creating rooms until we hit the max number of rooms:

```ruby
def make_rooms
  while rooms.count < MAX_NUMBER_OF_ROOMS
    rooms << create_room
  end
end
```

To draw our rooms we'll implement the following `draw_rooms` function:

```ruby
def draw_rooms
  rooms.each { |room| draw_rooms(room) }
end
```

If you run your code now, you'll get something akin to:

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

We can fix this by making sure the rooms we create do not overlap. In order to do this, when we create a room that fills our current rectangle, we'll split that rectangle into 4 small ones that exclude our room. Then when we run `create_room` again we'll randomly select a new rectangle and attempt to fit a new room into it.


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

  private

  # add rooms
  attr_reader :dungeon, :rects, :rooms

  # ...

  # modify the existing makerooms function
  def make_rooms
    while (rooms.count < MAX_NUMBER_OF_ROOMS) && rects.any?
      return unless create_room
    end
  end

  def create_room
    # ...

    room = Room.new(xabs, yabs, xabs+dx, yabs+dy)
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

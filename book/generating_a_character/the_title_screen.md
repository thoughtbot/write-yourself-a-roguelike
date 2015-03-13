## Chapter 1 - The Title Screen

Most gaming journeys begin with the fabled title screen - where we get to see the title of the game once again before we can begin. We're going to begin our journey the same way. To implement our title screen, and the rest of our game, we're going to need to make use of the `curses` gem. If you dont already have `curses` installed you can get it via:

    gem install curses

The NetHack title screen is relativly simple as you can see here:

![character selection](images/character.png?raw=true =600x)

Let's start our game by writing the simplest curses example we can come up with. The program will initialize curses, read a single character, and then quit. To do this, create a file named `main.rb` and add the following:

```ruby
require "curses" # require the curses gem
include Curses   # mixin curses

# The next three functions are provided by including the Curses module.

init_screen      # starts curses visual mode
getch            # reads a single character from stdin
close_screen     # closes the ncurses screen
```

If you run this program, you will see the terminal go black and upon pressing a character it will return back to normal.

Now that we've got a simple curses example running, let's work on our title screen. We're going to break our code up into three files. The first file we'll create is named `game.rb` and it should contain the following:

```ruby
class Game
  def initialize
    @ui = UI.new
    at_exit { ui.close } # runs at program exit
  end

  def run
    title_screen
  end

  private

  attr_reader :ui

  def title_screen
    ui.message(0, 0, "Rhack, a NetHack clone")
    ui.message(7, 1, "by a daring developer")
    ui.choice_prompt(0, 3, "Shall I pick a character's race, role, gender and " + 
      "alignment for you? [ynq]", "ynq")
  end
end
```

Then create the file `ui.rb` with:

```ruby
class UI
  include Curses

  def initialize
    noecho # do not print characters the user types
    init_screen
  end

  def close
    close_screen
  end

  def message(x, y, string)
    setpos(y, x) # positions the cursor - pay attention to the argument order here
    addstr(string) # prints a string at cursor position
  end

  def choice_prompt(x, y, string, choices)
    message(x, y, string + " ")

    loop do
      choice = getch
      return choice if choices.include?(choice)
    end
  end
end
```

Finally, change your `main.rb` to:

```ruby
$LOAD_PATH.unshift "." # makes requiring files easier

require "curses"
require "ui"
require "game"

Game.new.run
```

I've chosen to break the UI into its own class for a few reasons. First, in game development, it's easy to produce code that is difficult to understand. We want to avoid this by trying to employ the single-responsibility pattern as much as possible. Tangentally, if we decide to replace our UI implementation with a different one, the isolation here makes doing that far easier.

The responsibility of our `Game` class will be to  manage all of our global state and the execute the main run loop.

If you run the program now, it will look very much like the initial NetHack screen.

![Rhack](images/rhack.png?raw=true =600x)

Moving forward, we're going to want to show more than a title screen. Let's start by refactoring our current code into something more adaptable. Refactor `game.rb` to the following:

```ruby
class Game
  def initialize
    @ui = UI.new
    @options = { quit: false, randall: false } # variable for options
    at_exit { ui.close; p options } # See selected options at exit
  end

  def run
    title_screen
  end

  private

  attr_reader :ui, :options # Add attr_reader for options

  def title_screen
    TitleScreen.new(ui, options).render
    quit?
  end

  def quit?
    exit if options[:quit]
  end
end
```

Now we'll create a `title_screen.rb` file with the following:

```ruby
class TitleScreen
  def initialize(ui, options)
    @ui = ui
    @options = options
  end

  def render
    ui.message(0, 0, "Rhack, a NetHack clone")
    ui.message(7, 1, "by a daring developer")
    handle_choice prompt
  end

  private

  attr_reader :ui, :options

  def prompt
    ui.choice_prompt(0, 3, "Shall I pick a character's race, role, gender and " + 
      "alignment for you? [ynq]", "ynq")
  end

  def handle_choice(choice)
    case choice
    when "q" then options[:quit] = true
    when "y" then options[:randall] = true
    end
  end
end
```

You can see here how we'll be making use of the `options` variable created in `game.rb`. It will store the selections the user makes during setup. We need to do this in order to communicate between the different selection screens about what choices the player has made. If the user selects "q" we'll store that we need to quit, if they choose "y" then we'll randomly assign the rest of the traits. In order to keep our application working you'll also need to add:

```ruby
require "title_screen"
```

to `main.rb`. Now when running the program and choose an option you'll see set in the output that is printed. For instance, if I select yes, then I'll see the following:

```ruby
{:quit=>false, :randall=>true}
```

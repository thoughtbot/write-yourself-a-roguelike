# Write a Roguelike

## Part 2 - Creating a Character
### Chapter 5 - The Title Screen

To begin our journey we'll first need to learn how to use the `curses` gem. If you haven't already, begin by installing the gem via:

    gem install curses
    
Once that finishes installing, we'll continue by first examining the NetHack title screen because we'll want our title screen to mimic it.

![character selection](images/character.png?raw=true =600x)

Let's start our game by first writing the simplest curses example we can come up with. We'll initialize curses, read a single character, and quit. To do that, create a file named `main.rb` and add the following:

    require "curses" # require the curses gem
    include Curses   # mixin curses
    
    # The next three functions are provided by including the Curses module.
    
    init_screen      # starts curses visual mode
    getch            # reads a single character from stdin
    close_screen     # closes the ncurses screen
    
If you run this program, you will see the terminal go black and upon pressing a character it will return back to normal.

Now that we've got a simple curses example running let's work on our title screen. We're going to break our code up into three files. The first file we'll create is named `game.rb` and it will contain the following:

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
        ui.choice_prompt(0, 3, "Shall I pick a character's race, role, gender and alignment for you? [ynq]", "ynq")
      end
    end
    
Then create the file `ui.rb` with:

    class UI
      include Curses
      
      def initialize
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
    
Finally, change your main.rb to the following:

    $LOAD_PATH.unshift "." # makes requiring files easier
    
    require "curses"
    require "ui"
    require "game"
    
    Game.new.run
    
I've chosen to break the UI into its own class for a few reasons. First, in game development, it's easy to produce difficult to understand code. We want to avoid this by trying to employ the single-responsibility pattern as much as possible. Tangentally, if we wanted to replace our UI with a different implementation the isolation here makes doing so far easier.

TODO: verify the assumption below

The responsibility of our game class is really to manage all of our global state. When writing games, you will often have an object that many other objects need to know something about (which is often referred to as the game state). We'll be storing and managing our game state in this `Game` class.

![Rhack](images/rhack.png?raw=true =600x)

If you run the program now, it will look very much like the initial NetHack screen.

Moving forward, we're going to want to show more than a title screen. Let's start prepairing for this by refactoring our current code into something more adaptable. Let's make some quick changes in `game.rb`:

    class Game
      def initialize
        @ui = UI.new
        @options = { quit: false, randall: false } # variable for options
        at_exit { ui.close, p options } # See selected options at exit
      end

      def run
        title_screen
      end

      private

      attr_reader :ui, :options # Add attr_reader for options

      def title_screen
        TitleScreen.new(ui, options).render
        exit if options[:quit]
      end
    end

Now we'll create a `title_screen.rb` file with the following:

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
        ui.choice_prompt(0, 3, "Shall I pick a character's race, role, gender and alignment for you? [ynq]", "ynq")
      end

      def handle_choice choice
        case choice
        when "q" then options[:quit] = true
        when "y" then options[:randall] = true
        end
      end
    end

TODO: Talk about in game options

You can see here how we'll be using the `options` variable assigned in `game.rb`. This will store the selections the user makes during setup. We need to do this in order to communicate between the different screens about what has been chosen. If the user selects "q" we'll store that we need to quit, if they choose "y" then we'll randomly assign the rest of the attributes. In order to keep our application working you'll also need to add:

    require "title_screen"

to `main.rb`. Now when you run the program you'll see what we've selected printed to the screen. For instance, if I select yes, I'll see the following:

    {:quit=>false, :randall=>true}

### Chapter 7 - Messages

There are going to be a lot of messages in the game and I prefer to extact them out into a yaml file. This makes them far easier to change (or to internationalize) later. Let's start by creating a `data` directory. This directory will hold some yaml files that will contain in game text and other data. In that directory, let's create a file for holding our in-game messages. Name the file `messages.yaml` and Add the following to it:

    ---
    title:
      name: Rhack, a NetHack clone
      by: by a daring developer
      pick_random: "Shall I pick a character's race, role, gender and alignment for you? [ynq]"

We'll want to update our `TitleScreen` class to make use of these. In order to do that, we'll first need some way to load the yaml file. It's good idea to isolate external dependencies like YAML to a single location to make them easier to replace in the future. We took that approach with Curses by extracting out the UI into its own class. In this situation, we'll extract out a `DataLoader` class that knows how to load data for us. Create a `data_loader.rb` file with the following:

    class DataLoader
      def self.load_file(file)
        new.load_file(file)
      end

      def load_file(file)
        symbolize_keys YAML.load_file("data/#{file}.yaml")
      end

      private

      def symbolize_keys(object)
        case object
        when Hash
          object.each_with_object({}) do |(key, value), hash|
            hash[key.to_sym] = symbolize_keys(value)
          end
        when Array
          object.map { |element| symbolize_keys(element) }
        else
          object
        end
      end
    end

The reason behind `symbolize_keys` is that YAML will parse all the keys as strings and I prefer symbols for this. If you'd like you can add `ActiveSupport` as a dependency which implements `deep_symbolize_keys` on `Hash`, but I chose not to add such a large dependency to this project.

Now we'll create a global way to access these messages. Create a file called `messages.rb` with the following:

    module Messages
      def self.messages
        @messages ||= DataLoader.load_file("messages")
      end

      def self.[](key)
        messages[key]
      end
    end

It's evident here that our Messages module knows nothing about the YAML backend, instead it simply asks our DataLoader to load the messages. Now that we have a way to get our messages let's change our `title_screen.rb` to make use of it. In initialize add the following:

    @messages = Message[:title]

Make sure to add `:messages` to the `attr_reader` line and then change render to the following:

  ui.message(0, 0, messages[:name])
  ui.message(7, 1, messages[:by])
  handle_choice prompt

Now to finish up, add `require`s in `main.rb` for `yaml`, `data_loader`, and `messages`. When you run the program again it should still function like our previous implementation.

### Chapter 8 - Setting the role

For a game like NetHack, there's a lot of information that goes in to creating a character. From a top level, a character will have a role, race, gender, and alignment. Each of these traits will determine how a game session will play.

We'll start by allowing the player to choose their role. In NetHack these are the roles a player can select:

![selection](images/role.png?raw=true =600x)

We'll be implementing all of these. Looking at this list, you should immediately be thinking "data." We're going to create another data file to hold information for our roles. To start we're just going to give each role a name and a hotkey. Create `data/roles.yaml` with the following:

    ---
    - name: Acheologist
      hotkey: a
    - name: Barbarian
      hotkey: b
    - name: Caveman
      hotkey: d
    - name: Healer
      hotkey: h
    - name: Knight
      hotkey: k
    - name: Monk
      hotkey: m
    - name: Priest
      hotkey: p
    - name: Rogue
      hotkey: r
    - name: Ranger
      hotkey: R
    - name: Samurai
      hotkey: s
    - name: Tourist
      hotkey: t
    - name: Valkyrie
      hotkey: v
    - name: Wizard
      hotkey: w

Now we're going to create a `Role` class that can load all of this data. Create a file named `role.rb` with the following:

    class Role
      def self.for_options(_)
        DataLoader.load_file("roles").map do |data|
          Role.new(data)
        end
      end

      attr_reader :name, :hotkey

      def initialize(data)
        data.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def to_s
        name
      Since rend
    end

We're using for_options here to unify the interface across all of our characteristics, since race and alignment will be dependent on role. We'll see shortly why this abstraction makes sense.

### Chapter 9 - Setting the race

![selection](images/race.png?raw=true =600x)

Our race will determine which alignments we can choose as well as some starting stat bonuses. Your race will also determine your starting alignment. Dwarves are lawful, gnomes are neutral, elves and orcs are chaotic, and humans can be any alignment (but this might be restricted by the role chosen e.g. samurai are lawful). In terms of stats, dwarves are typically stronger, gnomes and elves are generally smarter, and humans are generally balanced across the stats.

### Chapter 10 - Setting the gender

![selection](images/gender.png?raw=true =600x)

For our purposes, gender will determine which pronoun your character will be addressed with. In actual NetHack gender does affect some interactions in the game, but we won't be going that in depth with our implementation.

### Chapter 11 - Setting alignment

![selection](images/alignment.png?raw=true =600x)

Finally, alignment determines how the actions you take in game will affect you. If you do things that contrast your alignment your god will be angry with you and the game will become more difficult.

### Chapter 12 - Generating Stats

So once a player has chosen their role, race, gender, and alignment, we'll need to calculate their character's base stats. In NetHack you have stats for strength, wisdom, intellegence, dexterity, charisma, and constitution. We will allocate a total of 75 points to these stats. Based on a player's role, we'll allocate a specific amount of those points to each stat. The leftover points are then allocated randomly according to rules set by the player's selected role.

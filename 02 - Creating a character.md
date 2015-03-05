# Write a Roguelike

## Part 2 - Creating a Character
### Chapter 5 - The Title Screen

To begin our journey we'll first need to learn how to use the `curses` gem. If you haven't already, begin by installing the gem via:

    gem install curses
    
Once that finishes installing, we'll continue by first examining the NetHack title screen.

->![character selection](images/character.png?raw=true =600x)<-

We'll want our title screen to mimic the NetHack one. Let's dive into curses by first writing the simplest curses example we can come up with. We'll initialize curses, read a single character, and quit. To do that, create a file named `main.rb` and add the following:

    require "curses" # require the curses gem
    include Curses   # mixin curses
    
    # The next three functions are provided by including the Curses module.
    
    init_screen      # starts curses visual mode
    getch            # reads a single character from stdin
    close_screen     # closes the ncurses screen
    
If you run this program, you will see the terminal go black and upon pressing a character it will return back to normal.

Now that we've got a curses example running let's work on our title screen. We're going to break up our code into three files. The first file we create we'll call `game.rb` and it will contain the following:

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
        ui.prompt(0, 3, "Shall I pick a character's race, role, gender and alignment for you? [ynq]")
      end
    end
    
Then create a `ui.rb` file:

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
      
      def prompt(x, y, string)
      	string += " "
        message(x, y, string)
        getch
      end
    end
    
Finally, change your main.rb to the following:

    $LOAD_PATH.unshift "." # makes requiring files easier
    
    require "curses"
    require "ui"
    require "game"
    
    Game.new.run
    
I've chosen to break the UI into its own class for a few reasons. First, in game development, it's really easy to produce difficult to understand code, we want to avoid this by trying to employ the single-responsibility pattern as much as possible. Tangentally, if we wanted to replace our UI with a different implementation the isolation here makes it far easier to do.

TODO: verify this assumption

The responsibility of our game class is really to handle all of our global state. You will find when writing most games that at some point you'll have an object that practically everything needs to know about (which is often referred to as the game state). We'll be storing and managing our game state in this class as we progress. 

->![Rhack](images/rhack.png?raw=true =600x)<-

If you run the program now, it will look very much like the initial NetHack screen. As an added bonus the `q` key already works correctly, but then again every key quits. Let's start working on character details.

### Roles, Races, Genders, Alignments, and a small refactoring

There's a lot of information that goes in to creating a character. From a top level, our character will have a role, race, gender, and alignment. Each of these traits will determine how your game will play.

The role determines a large number of things. The parts we'll care about up front are which race and alignments a player can choose, as well as how stats are allocated to a player.

Our race will determine which alignments we can choose as well as some starting stat bonuses. For alignments dwarves are lawful, gnomes are neutral, elves and orcs are chaotic, and humans can be any alignment (but this might be restricted by the chosen role e.g. Samurai are lawful). For starting stats dwarves are typically stronger, gnomes and elves are generally smarter, and humans are generally balanced across the stats.

Gender is mainly for choosing which pronoun your character will be addressed with, but there are also some in game interactions that are gender dependent.

Finally alignment determines how the actions you take in game affect you. If you do things that contrast your alignment your god will be angry with you and the game will become more difficult.

After a player has made all of their choices, we'll need to calculate their character's base stats. For strength, wisdom, intellegence, dexterity, charisma, and constitution we allocate a total of 75 points. Based on the player's role we'll allocate a specific amount of those points to each category. The points left over are allocated according to rules set by the player's selected role.

If we look at all the selection screens in NetHack you'll notice that they look mostly the same.

->![selection](images/role.png?raw=true =600x)<-

->![selection](images/race.png?raw=true =600x)<-

->![selection](images/gender.png?raw=true =600x)<-

->![selection](images/alignment.png?raw=true =600x)<-

We'll want to abstract this as much as possible to prevent duplication. This will require a lot of abstractions, but they will pay off greatly in the long run. Let's make some quick changes in `game.rb`:

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
        ui.prompt(0, 3, "Shall I pick a character's race, role, gender and alignment for you? [ynq]")
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

### Messages

There are going to be a lot of messages in the game and I prefer to extact them out into a yaml file. This makes them far easier to change (or to internationalize) later. Let's start by creating a `data` directory. This directory will hold some yaml files that will contain in game text and other information. In that directory let's create a file for holding messages we'll print to the screen. Name the file `messages.yaml` and Add the following to it:

    ---
    title:
      name: Rhack, a NetHack clone
      by: by a daring developer
      pick_random: "Shall I pick a character's race, role, gender and alignment for you? [ynq]"

Now we'd like to use thse for our existing title screen. First we'll need some way to load the yaml file. It's good idea to isolate external dependencies like YAML to a single location to make them easier to replace in the future. We did the same thing with Curses by extracting out the UI class. So if we decide to implement Rhack with JSON and an OpenGL interface e have only two places we'll need to change in order to make that work. Create a `data_loader.rb` file with the following:

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

The reason behind symbolize keys is that YAML will parse all the keys as strings and I prefer symbols for this. You can choose to require `ActiveSupport` which implements this method on `Hash`, but I chose not to add such a large dependency to this project.

Now we'll create a global way to access these messages. Create a file called `messages.rb` with the following:

    module Messages
      def self.messages
        @messages ||= DataLoader.load_file("messages")
      end

      def self.[](key)
        messages[key]
      end
    end

It's evident here that our Messages module knows nothing about the YAML backend. This module is mainly for convenience. With this in place let's change our `title_screen.rb` to make use of this. In initialize add the following:

    @messages = Message[:title]

Make sure to add `:messages` to our `attr_reader` and then change render to the following:

  ui.message(0, 0, messages[:name])
  ui.message(7, 1, messages[:by])
  handle_choice prompt

Now you can finish up by adding `require`s in `main.rb` for `yaml`, `data_loader`, and `messages`. When you run the program it should still function like our previous implementation.

### Setting the role

Here we see a long list of character types. Whenever you see lists of data like this, you first thought should be to use a data format such as YAML, JSON, or XML. We're going to use the defacto Ruby YAML library for our data. Let's create a `roles.yaml` file with the following:

    ---                                                 
    - name: "Archeologist"     
      hotkey: "a"              
    - name: "Barbarian"        
      hotkey: "b"              
    - name: "Caveman/Cavewoman"
      hotkey: "c"              
    - name: "Healer"           
      hotkey: "h"              
    - name: "Knight"           
      hotkey: "k"              
    - name: "Monk"             
      hotkey: "m"              
    - name: "Priest/Priestess" 
      hotkey: "p"              
    - name: "Rogue"            
      hotkey: "r"              
    - name: "Ranger"           
      hotkey: "R"              
    - name: "Samurai"          
      hotkey: "s"              
    - name: "Tourist"          
      hotkey: "t"              
    - name: "Valkyrie"         
      hotkey: "v"              
    - name: "Wizard"           
      hotkey: "w"
        
This YAML file will make it very easy to extend our role definitions to include starting stats, items, pets, etc. Let's start by printing out all of our roles when the user presses `n`:

    require 'curses'                                                                      
    require 'yaml'                                                                        
                                                                                      
    ROLES_FILE = "roles.yaml"                                                             
    include Curses                                                                        
                                                                                      
    begin                                                                                 
      init_screen                                                                                                                                              
      roles = YAML.load_file(ROLES_FILE)                                                  
      setpos(1, 0)                                                                        
      addstr("RHack, Copyright 2015")                                                     
      setpos(2, 7)                                                                        
      addstr("By a daring developer, inspired by Nethack.")                               
      setpos(3, 7)                                                                        
      addstr("See license for details.")                                                  
      setpos(6, 0)                                                                        
      addstr("Shall I pick a character's race, role, gender and alignment for you? [ynq]")
      choice = getch                                                                      
      if choice == 'n'                                                                    
        clear                                                                             
        roles.each_with_index do |role, index|                                            
          setpos(index, 0)                                                                
          addstr(role["name"])                                                            
        end                                                                               
        getch                                                                             
      end                                                                                 
    ensure                                                                                
      close_screen                                                                        
    end                                                                                                

Here we introduce `clear` which will completely clear the entire screen. After that we simply iterate through all the role options. Before we go too far down the rabbit hole, let's start refactoring what we have into object-oriented code


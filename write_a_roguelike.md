# Write a Roguelike

## Intro

You are about to embark on a journey. This journey will be plagued with orcs, gnomes, algorithms, data structures, and kittens. You, valiant developer, will be writing a Roguelike.

If you are reading this book, then bets are you already know what a roguelike is. But let us pretend for a moment that you do not and briefly go over some ground rules:

* Proceduraly generated environments
* Turn-based gameplay
* Tile-based maps
* Permanent death

In this vein, we will design our roguelike to be akin to the game NetHack. NetHack is an ASCII based roguelike originally released in 1987, but it is currently still being further developed. As we build our roguelike, we will continously reference NetHack for both implementation and inspiration.

## Creating a Character
### Starting with Ncurses - The Title Screen

There's a lot of information that goes in to creating a character. From a top level, our character will have a role, race, gender, and alignment. The role determines which pantheon of gods will be active during the game. Our role and race combined will determine our starting stats (strength, dexterity, intelligence, wisdom, constitution, charisma, hit points, and energy) as well as how our stats change when we level up. Gender is simply for preferred pronoun usage and alignment determines which god in our pantheon is the one we worship (or choose not to worship).

We'll need to take the corresponding steps to allow the player to choose their role, race, gender, and alignment. There are however some restrictions. Certain roles are restrited to which race and alignments are available. Similarly your race will limit which alignments are available.

Afterwards we'll need to calculate a characters base stats. For strength, wisdom, intellegence, dexterity, charisma, and constitution we allocate 75 points. A number of those points are determined by the player's role. The remaining points are allocated according to probabilities set by the selected role.

On the first screen of NetHack we see the following:

->![character selection](images/character.png =600x)<-

Interestingly enough we have already run into a few problems. For instance in ruby it is difficult to find a cross-platform way of clearing the screen. To this end, we are going to employ ncurses. More specifically, we will be using the rubygem `curses`. Originally, ncurses was part of ruby's stdlib, but is now maintained separately [here](https://github.com/ruby/curses).

Let us begin by setting up ncurses and clearing the screen. First run `gem install ncurses` and once that has finished create a file called `main.rb`. Add the following to that file:

    require 'curses'
    
    include Curses
    
    begin
      init_screen
    ensure
      close_screen
    end    

Both `init_screen` and `close_screen` are part of the `Curses` module we have included. When we run this program with `ruby main.rb` you will most likely see nothing happen. The reason behind this is that the screen is closing too fast. In order to delay closing the screen, let us add a call to `getch`. `getch` is an ncurses function for capturing a single keypress:

    begin
      init_screen
      getch
    ensure
      close_screen
    end
    
Now when you run the program again you will see a blank screen and upon pressing a single key you will be returned to your prompt. Now that we've "blanked" the screen, the next step is to create the initial screen from before. Let's call our implementation RHack.

    require 'curses'
    
    include Curses
    
    begin
      init_screen
      setpos(1, 0)                                                                        
      addstr("RHack, Copyright 2015")                                                     
      setpos(2, 7)                                                                        
      addstr("By a daring developer, inspired by Nethack.")                               
      setpos(3, 7)                                                                        
      addstr("See license for details.")                                                  
      setpos(6, 0)                                                                        
      addstr("Shall I pick a character's race, role, gender and alignment for you? [ynq]")
      getch
    ensure
      close_screen
    end

If you run the program now, it will look very much like the initial NetHack screen. As an added bonus the `q` key already works correctly, but then again every key quits. Let's start working on character details.

### Picking a Role

From the initial NetHack screen, if you press `n` you will see this screen:

->![selection](images/selection.png =600x)<-

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

### Picking a Race
### Picking a Gender
### Picking an Alignment
### Setting Character Stats

 

## Creating the Dungeon
### Generating random rooms
### Moving around
### Creating Stairwells
### Doors
### Vision
### Color
### Pets


## The Environment
### Random Monsters
### Combat
### Increasing Difficulty
### Items
### Food and Hunger




    


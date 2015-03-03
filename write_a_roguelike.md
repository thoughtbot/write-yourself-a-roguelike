# Write a Roguelike

## Part 1 - Intro

### Chapter 1 - What is a roguelike?

You are about to embark on a journey. This journey will be plagued with orcs, gnomes, algorithms, data structures, and kittens. You, valiant developer, will be writing a Roguelike.

If you are reading this book, then bets are you already know what a roguelike is. But let us pretend for a moment that you do not and briefly go over some ground rules:

* Proceduraly generated environments
* Turn-based gameplay
* Permanent death
* Tile-based maps

So where do these rules come from? Roguelike games get their rules and name from the game Rogue. Rogue was developed in the 1980s, but if you have ever played it, then it's clear that its influence has spread far and wide as evident in games like Dwarf Fortress (another personal favorite) or Diablo.

->![Rogue](images/rogue.png =600x)<-

As far as gameplay goes, you play an adventurer who descends into a dungeon for loot and fame. There is a catch though. Until you make it to the final level and retrieve the Amulet of Yendor, you are unable to return to the previous level. If you retrieve the Amulet of Yendor and make it back to the surface then you journey home, sell all of your loot, and get admitted to the fighters guild.

Now back to the rules because they are important for what we are trying to accomplish. A huge part of writing a good roguelike is the procedurally generated environments. These can be anything from dungeons to full worlds. The importance of the procedurally generated environments is replayability. You're unlikely to have a similar gaming experience between plays. It creates an incentive to play over and over. Our roguelike wouldn't be very fun if every time you played all the dungeons were the same.

In terms of gameplay, we'll be dealing with turn-based game play. As the player, you'll issue a single command and the entire world state will tick a single turn. This method of play creates great situations where you know you're in serious trouble, but have time to plan the next best move. It can become very tense when you've put a lot into your character and you're on the verge of dying.

Which brings us to the next rule... permanent death. This is the crux of a roguelike. If you die, you lose everything and have to start over. This means your choices have serious consequences and you can not just revert back to a save. This makes success very rewarding and failure very frustrating. Do you read scroll that could destroy your armor making you defenseless, but also could detect food you so desperately need?

Lastly, since we're using ASCII to communicate the game we're essentially dealing with tile-based gameplay. A character can move orthogonally and diagonally. This keeps interactions fairly straightforward, but it also means we're dealing strictly with 2-dimensional math (in most cases).

### Chapter 2 - What is NetHack

->![Nethack](images/nethack.png =600x)<-

NetHack is an ASCII based roguelike originally released in 1987, but it is currently still being further developed. It is a sort of evolution from Rogue. You're still descending down through levels and levels of dungeons to retrieve the Amulet of Yendor, but your goal now is to escape the dungeon, ascend through the elemental planes until you get to the astral plane in which you offer the amulet to your assigned god and are granted demigodhood (never thought I'd type that word).

There are also a number of other aspects that make NetHack more interesting. There is considerable depth added on top of the original Rogue-formula. Instead of being a generic adventurer you can be a samurai, valkyrie, tourist, or other role each with their own specific quest. You have a race and alignment which will affect how monsters interact with you and even what you can do in the game (at the cost of angering your god). There are multiple paths in the dungeon and you can return to earlier levels (usually necessary to win).

As we build our roguelike, we will continously reference NetHack for both implementation and inspiration. We can do this because NetHack is open source, and while the code-base is almost 30 years old, I've gone ahead and spent countless hours using lldb to figure out what's going on for you.

### Chapter 3 - Tooling

In order to make our roguelike we'll be using a few different tools. First off, we'll be using Ruby. I've chosen Ruby for this initial edition for a couple of reasons. First and foremost, I find Ruby to be fairly easy to understand and when I want to build something quickly it's my goto. Second, I feel like object-oriented programming lends itself fairly well for programming games. Lastly, it has Ncurses bindings available through the gem `curses`.

What is Ncurses you ask? Ncurses stands for New Curses, it's a freeware reimplementation of the original curses library. Its purpose is to make managing screen state easier and more portable. If you've ever installed some flavor of linux on a computer you might have seen something like this:

->![Ncurses example](images/ncurses-example.png =600x)<-

This screen was created using Ncurses. So why do **we** need Ncurses? After all, we're just writing a simple game. Using Ruby let's try to do something simple like clearing the screen. If you're on OSX you might have written something like:


    system("clear")

Everything works great until you try to run this code on Windows. It will fail on windows because there is no `clear.exe`. On Windows we need to run:

    system("CLS")
    
Now we'd need to run code to detect the OS. We'll need to import `rbconfig` and write some code to detect the OS and choose the correct code to run. We can avoid this by using Ncurses which will do all the heavy lifting for us.

We'll also be making heavy use of YAML. You could really use any data language you want (XML, JSON, etc.), but YAML seems to be a defacto choice for Ruby. We'll be using YAML to store the large amounts of data that is needed to write a game of this nature

### Chapter 4 - Why write this book

Game development was one of the things that first attracted me to developing software. I started in highschool with QBasic. Nowadays it's much harder to get started due to the complexities of graphical hardware and complex operating system interactions. There is a certain purity in an ASCII based game, there is very little overhead and very little math required to get started (but still very necessary as you will soon see). There is also a lot to be said about using one's imagination. Most games these days have taken that element away from me, I know what everything looks like because the game's artists have fleshed it all out. However, games like NetHack allow me to imagine what's going on and to in some ways weave my own story. Because I find playing games like NetHack I've found a lot of enjoyment in writing games like NetHack and I hope this book will help you share this journey.

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

### Picking a Role, Race, Gender, and Alignment

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


### Character Stats

 

## Creating the Dungeon
### Generating random rooms
### Generating Doors and Corridors
### Moving around
### Creating Stairwells
### Vision and Lighting
### Color


## Gameplay
### Random Monsters
### Combat
### Magic
### Items
### Food and Hunger
### Searching, hidden doors and corridors
### Saving and Loading
### Increasing Difficulty

## Possible Chapters
### Questlines
### Alternate Dungeon types
### Blessings and Curses




    


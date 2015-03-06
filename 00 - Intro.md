## Intro - the boring stuff

### Chapter i - What is a roguelike?

You are about to embark on a journey. This journey will be plagued with orcs, gnomes, algorithms, data structures, and kittens. You, valiant developer, will be writing a Roguelike.

If you are reading this book, then bets are you already know what a roguelike is. But let us pretend for a moment that you do not and briefly go over some ground rules:

* Proceduraly generated environments
* Turn-based gameplay
* Permanent death
* Tile-based maps

So where do these rules come from? Roguelike games get their rules and name from the game Rogue. Rogue was developed in the 1980s, but if you have ever played it, then it's clear that its influence has spread far and wide as evident in games like Dwarf Fortress (another personal favorite) or Diablo.

![Rogue](images/rogue.png?raw=true =600x)

As far as gameplay goes, you play an adventurer who descends into a dungeon for loot and fame. There is a catch though. Until you make it to the final level and retrieve the Amulet of Yendor, you are unable to return to the previous level. If you retrieve the Amulet of Yendor and make it back to the surface then you journey home, sell all of your loot, and get admitted to the fighters guild.

Now back to the rules because they are important for what we are trying to accomplish. A huge part of writing a good roguelike is the procedurally generated environments. These can be anything from dungeons to full worlds. The importance of the procedurally generated environments is replayability. You're unlikely to have a similar gaming experience between plays. It creates an incentive to play over and over. Our roguelike wouldn't be very fun if every time you played all the dungeons were the same.

In terms of gameplay, we'll be dealing with turn-based game play. As the player, you'll issue a single command and the entire world state will tick a single turn. This method of play creates great situations where you know you're in serious trouble, but have time to plan the next best move. It can become very tense when you've put a lot into your character and you're on the verge of dying.

Which brings us to the next rule... permanent death. This is the crux of a roguelike. If you die, you lose everything and have to start over. This means your choices have serious consequences and you can not just revert back to a save. This makes success very rewarding and failure very frustrating. Do you read scroll that could destroy your armor making you defenseless, but also could detect food you so desperately need?

Lastly, since we're using ASCII to communicate the game we're essentially dealing with tile-based gameplay. A character can move orthogonally and diagonally. This keeps interactions fairly straightforward, but it also means we're dealing strictly with 2-dimensional math (in most cases).

### Chapter ii - What is NetHack?

![Nethack](images/nethack.png?raw=true =600x)

NetHack is an ASCII based roguelike originally released in 1987, but it is currently still being further developed. It is a sort of evolution from Rogue. You're still descending down through levels and levels of dungeons to retrieve the Amulet of Yendor, but your goal now is to escape the dungeon, ascend through the elemental planes until you get to the astral plane in which you offer the amulet to your assigned god and are granted demigodhood (never thought I'd type that word).

There are also a number of other aspects that make NetHack more interesting. There is considerable depth added on top of the original Rogue-formula. Instead of being a generic adventurer you can be a samurai, valkyrie, tourist, or other role each with their own specific quest. You have a race and alignment which will affect how monsters interact with you and even what you can do in the game (at the cost of angering your god). There are multiple paths in the dungeon and you can return to earlier levels (usually necessary to win).

As we build our roguelike, we will continously reference NetHack for both implementation and inspiration. We can do this because NetHack is open source, and while the code-base is almost 30 years old, I've gone ahead and spent countless hours using lldb to figure out what's going on for you.

### Chapter iii - Tooling

In order to make our roguelike we'll be using a few different tools. First off, we'll be using Ruby. I've chosen Ruby for this initial edition for a couple of reasons. First and foremost, I find Ruby to be fairly easy to understand and when I want to build something quickly it's my goto. Second, I feel like object-oriented programming lends itself fairly well for programming games. Lastly, it has Ncurses bindings available through the gem `curses`.

What is Ncurses you ask? Ncurses stands for New Curses, it's a freeware reimplementation of the original curses library. Its purpose is to make managing screen state easier and more portable. If you've ever installed some flavor of linux on a computer you might have seen something like this:

![Ncurses example](images/ncurses-example.png?raw=true =600x)

This screen was created using Ncurses. So why do **we** need Ncurses? After all, we're just writing a simple game. Using Ruby let's try to do something simple like clearing the screen. If you're on OSX you might have written something like:


    system("clear")

Everything works great until you try to run this code on Windows. It will fail on windows because there is no `clear.exe`. On Windows we need to run:

    system("CLS")
    
Now we'd need to run code to detect the OS. We'll need to import `rbconfig` and write some code to detect the OS and choose the correct code to run. We can avoid this by using Ncurses which will do all the heavy lifting for us.

We'll also be making heavy use of YAML. You could really use any data language you want (XML, JSON, etc.), but YAML seems to be a defacto choice for Ruby. We'll be using YAML to store the large amounts of data that is needed to write a game of this nature.


### Chapter iv - Why write this book?

The reason I decided to write this book is because game development was one of the things that first attracted me to developing software. I started programming in highschool with QBasic. QBasic made it pretty easy to enter into a graphics mode and start drawing on the screen. It wasn't long before I had written a very primitive RPG. Nowadays, it's much harder to get started due to the complexities of graphical hardware and complex operating system interactions. Roguelikes allow us to simplfy things one again.

There is a certain purity in an ASCII based game - there is very little overhead and very little math required to get started. Imagination also plays a large role. Most games these days have taken imagination out of the equation. I know what everything looks like because the game's artists have fleshed it all out. However, games like NetHack allow me to imagine what's going on and to in some ways weave my own story.

Because I've found a lot of enjoyment in playing games like NetHack, I've developed a natural curiosity for the internal workings. How would one go about creating the same kind of game? I've spent considerable time diving in and out of the C code to answer that question. I hope this book will answer that question for you as well.


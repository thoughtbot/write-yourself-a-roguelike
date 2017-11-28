## Chapter 1 - The Title Screen

Most gaming journeys begin with the fabled title screen - where we get to see the title of the game once again before we can begin. We're going to begin our journey the same way. To implement our title screen, and the rest of our game, we're going to need to make use of the `curses` gem. If you don't have ncurses installed on your computer, please go back and read the tooling chapter in the introduction. If you have `ncurses` installed, but don't already have the `curses` gem, you can install it via:

    gem install curses

If this fails with "Failed to build gem native extension." you might not have `ncurses` properly installed and should reference the tooling chapter for installation instructions.

Now that we have the curses gem installed, we can start working on the title screen. We're going to base this on the NetHack title screen. The NetHack title screen is relativly simple as you can see here:

![](figures/character.png)

Let's start our game by writing the simplest curses example we can come up with. The program will initialize curses, read a single character, and then quit. To do this, create a file named `main.rb` and add the following:

!{code/2_1_title_screen_1.rb}

If you run this program, you will see the terminal go black and upon pressing a character it will return back to normal.

Now that we've got a simple curses example running, let's work on our title screen. We're going to break our code up into three files. The first file we'll create is named `ui.rb`. This will hold all of our interface routines.  We're breaking the UI into its own class for a few reasons. First, in game development, it's easy to produce code that is difficult to understand. We want to avoid this by trying to employ the single-responsibility pattern as much as possible. Tangentally, if we decide to replace our UI implementation with a different one, the isolation here makes doing that far easier. The implementation for our `UI` class will look like this:

!{code/2_1_title_screen_2.rb}

You may be wondering why we're passing values in (y, x) order instead of (x, y). We're passing the values as (y, x) because that's the order ncurses will expect to see them in. Ncurses wants the coordinates in (y, x) order because of how it renders the screen. Essentially, ncurses will start in the top left of the screen, y = 0, and then write out the entire line before moving on to the next line, y = 1. By storing the y coordinate first it can handle this process more optimally.

Now let's create the file `game.rb` which will hold our `Game` class. The responsibility of the `Game` class is to execute the main run loop as well as manage setup and global state. The implementation for the `Game` class will look like this:

!{code/2_1_title_screen_3.rb}

Finally, change the `main.rb` file to use our new classes:

!{code/2_1_title_screen_4.rb}

If you run the program now, it will look very much like the initial NetHack screen.

![](figures/rhack.png)

Moving forward, we're going to want to show more than a title screen. Let's start by refactoring our current code into something more adaptable. Refactor `game.rb` to the following:

!{code/2_1_title_screen_5.rb}

Now we'll create a `title_screen.rb` file with the following:

!{code/2_1_title_screen_6.rb}

You can see here how we'll be making use of the `options` variable created in `game.rb`. It will store the selections the user makes during setup. We need to do this in order to communicate between the different selection screens about what choices the player has made. If the user selects "q" we'll store that we need to quit, if they choose "y" then we'll randomly assign the rest of the traits. In order to keep our application working you'll also need to add:

!{code/2_1_title_screen_7.rb}

to `main.rb`. Now when running the program and choose an option you'll see set in the output that is printed. For instance, if I select yes, then I'll see the following:

    {:quit=>false, :randall=>true}

## Chapter iii - Tooling

In order to make our roguelike we'll be using a few different tools. First off, we'll be using Ruby. I've chosen Ruby for this initial edition for a couple of reasons. First and foremost, I find Ruby to be fairly easy to understand and when I want to build something quickly it's my goto. Second, I feel like object-oriented programming lends itself fairly well for programming games. Lastly, it has Ncurses bindings available through the gem `curses`.

What is Ncurses you ask? Ncurses stands for New Curses, it's a freeware reimplementation of the original curses library. Its purpose is to make managing screen state easier and more portable. If you've ever installed some flavor of linux on a computer you might have seen something like this:

![Ncurses example](images/ncurses-example.png?raw=true =600x)

This screen was created using Ncurses. So why do **we** need Ncurses? After all, we're just writing a simple game. Using Ruby let's try to do something simple like clearing the screen. If you're on OSX you might have written something like:


    system("clear")

Everything works great until you try to run this code on Windows. It will fail on windows because there is no `clear.exe`. On Windows we need to run:

    system("CLS")
    
Now we'd need to run code to detect the OS. We'll need to import `rbconfig` and write some code to detect the OS and choose the correct code to run. We can avoid this by using Ncurses which will do all the heavy lifting for us.

We'll also be making heavy use of YAML. You could really use any data language you want (XML, JSON, etc.), but YAML seems to be a defacto choice for Ruby. We'll be using YAML to store the large amounts of data that is needed to write a game of this nature.

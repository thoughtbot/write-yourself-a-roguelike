## Chapter iii - Tooling

In order to make our roguelike we'll be using a few different tools. First off, we'll be using Ruby. I've chosen Ruby for this initial edition for a couple of reasons. First and foremost, I find Ruby to be fairly easy to understand and when I want to build something quickly it's my goto. Second, I feel like object-oriented programming lends itself fairly well for programming games. Lastly, it has ncurses bindings available through the gem `curses`.

What is ncurses you ask? ncurses stands for *new curses*, it's a freeware reimplementation of the original curses library. Its purpose is to make managing screen state easier and more portable. If you've ever installed some flavor of linux on a computer you might have seen something like this:

\includegraphics[width=\linewidth]{images/ncurses-example.png}

This screen was created using Ncurses. So why do *we* need Ncurses? After all, we're just writing a simple game. Using Ruby let's try to do something simple like clearing the screen. If you're on macOS you might have written something like:

```ruby
system("clear")
```

Everything works great until you try to run this code on Windows. It will fail on Windows because there is no `clear.exe`. On Windows we need to run:

```ruby
system("CLS")
```

Now we'd need to run code to detect the OS. We'd need to import `rbconfig` and write some code to detect the OS and choose the correct code to run. We can avoid this by using ncurses, which will do all the heavy lifting for us. In order to use it, you'll need to make sure you have ncurses installed on your system. For Windows, you'll most likely want to use a version of Ruby that comes with ncurses in its standard library. In my case, I've gotten it running by using ruby 1.9.3p484. If you're using a Unix-based system you can most likely run `man ncurses` and if a man page comes up you should be set. If nothing comes up you'll want to install `ncurses-dev` via whatever package manager your system utilizes.

In addition to using `curses`, we'll also be making heavy use of YAML. You could really use any data language you want (XML, JSON, etc.), but YAML seems to be a defacto choice for Ruby. We'll be using YAML to store the large amounts of data that is needed to write a game of this nature.

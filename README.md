# Write Yourself a Roguelike

You are about to embark on a journey. This journey will be plagued with orcs,
gnomes, algorithms, data structures, and kittens. You, valiant developer, will
be writing a Roguelike.

## Outline

- [x] Intro
  - [x] What is a Roguelike?
  - [x] What is NetHack?
  - [x] Tooling
  - [x] Why Write This Book?

- [x] Creating a Character
  - [x] The Title Screen
  - [x] Messages
  - [x] Roles
  - [x] Races
  - [x] Genders
  - [x] Alignments
  - [x] Generating Abilities

- [ ] Creating the Dungeon
  - [ ] Generating random rooms
  - [ ] Generating Doors and Corridors
  - [ ] Moving around
  - [ ] Creating Stairwells
  - [ ] Vision and Lighting
  - [ ] Color

- [ ] Inventory
  - [ ] Items
  - [ ] Burden
  - [ ] Money and Shops
  - [ ] Food and Hunger
  - [ ] Unidentified Items

- [ ] Combat
  - [ ] Random Monsters
  - [ ] Combat
  - [ ] Magic

- [ ] Wrapping up
  - [ ] Saving and Loading
  - [ ] Increasing Difficulty
  - [ ] What to do next

- [ ] Possible Future Chapters
  - [ ] Searching, hidden doors and corridors
  - [ ] Questlines
  - [ ] Alternate Dungeon types
  - [ ] Blessings and Curses
  - [ ] Pets
  - [ ] Zoos

## Building

There is a build tool included with this project that will allow you to compile the contents of the `book` directory into an EPUB-formatted e-book. First, to ensure that you’ve got the necessary dependencies for the compilation process, change to the project directory and run:

    $ bundle install

We then need to have [Pandoc](http://pandoc.org/installing.html) installed.

Now, anytime you’d like to compile the book you can simply run the compile script:

    $ exe/compile

Doing so will write a file entitled `write-yourself-a-roguelike.epub` to the `release` directory, overwriting any existing file with the same name.

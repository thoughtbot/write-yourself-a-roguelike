# Write Yourself a Roguelike

You are about to embark on a journey. This journey will be plagued with orcs,
gnomes, algorithms, data structures, and kittens. You, valiant developer, will
be writing a Roguelike.

## Releasing an update

We're using tags and releases to track milestones in book updates.

* Upload sample.pdf to <http://thoughtbot.com/write-yourself-a-roguelike-sample.pdf> by
  updating the website repo (samples are in public/).
* Build a zip of non-sample content:

  ```
  $ paperback build
  $ cd build/write-yourself-a-roguelike
  $ rm write-yourself-a-roguelike.zip
  $ zip write-yourself-a-roguelike.zip images/* write-yourself-a-roguelike.*
  ```
* Upload the zip to Gumroad and attach it to the GitHub release.

## Outline

- [x] Intro
  - [x] About Nethack
  - [x] About Ncurses

- [x] Creating a Character
  - [x] Starting with Ncurses - The Title Screen
  - [x] Picking a Role, Race, Gender, and Alignment
  - [x] Assigning the Pantheon
  - [x] Character Stats

- [ ] Creating the Dungeon
  - [x] Generating random rooms
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

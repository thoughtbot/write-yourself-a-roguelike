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

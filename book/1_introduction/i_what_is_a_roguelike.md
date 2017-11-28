## Chapter i - What is a roguelike?

You are about to embark on a journey. This journey will be plagued with orcs, gnomes, algorithms, data structures, and kittens. You, valiant developer, will be writing a Roguelike.

If you are reading this book, then bets are you already know what a roguelike is, but let's go over some quick ground rules for what a roguelike should have:

* Proceduraly generated environments
* Turn-based gameplay
* Permanent death
* Tile-based maps

So where do these rules come from? Roguelike games get their rules and name from the game Rogue. Rogue was developed in the 1980s, but if you have ever played it, then it's clear that its influence has spread far and wide as evident in games like Dwarf Fortress and Diablo.

![](figures/rogue.png)

In Rogue, you play as an adventurer who descends into a dungeon for loot and fame. There is a catch though. Until you make it to the final level and retrieve the Amulet of Yendor, you are unable to return to the previous level. If you retrieve the Amulet of Yendor and make it back to the surface then you journey home, sell all of your loot, and get admitted to the fighters guild. Huzzah!

Now, let's get  back to the rules because they are important for the task at hand. A huge part of writing a good roguelike is the procedurally generated environments. These can be anything from dungeons to entire worlds. The importance of the procedurally generated environments is replayability. You're unlikely to have a similar gaming experience between plays. It creates an incentive to play over and over. Our roguelike will be far more exciting if one time you play you put on cursed boots and starve to death because you can't reach the floor and the next time you get assaulted by a feral kitten early in the game.

An important part of a roguelike game is having to think very hard about your next move. Quick! You're about to die! Do you pray, do you write "Elbereth" on the ground hopping the never ending assult of ants will leave your pitiful tourist alone! Each keypress could be your last. For this reason most roguelikes are turn-based. As the player, you'll issue a single command and the entire world will update. This gives you a chance to examine all the changes and carefully plan how you'll deal with the situation at hand.

Which brings us to the next rule... permanent death! This is the crux of a roguelike. If you die, you lose EVERYTHING and have to start over. All your hard work! That amazing wand you found! All gone! This means your choices have serious consequences. This makes success very rewarding and failure very frustrating. Do you read a scroll that could destroy your armor making you defenseless, but also could detect food you so desperately need? This tension is rarely found in games of other ilk.

And now, for the final roguelike rule. Our entire world will be tile-based. A character can move orthogonally and diagonally between tiles. This perspective and the use of ASCII to represent our game will allow it to run in terminals all across the world.

## Chapter 3 - Role call

For a game like NetHack, there is a lot of information that goes in to creating a character. From a top level, a character will have a role, race, gender and alignment. Each of these traits will determine how a game session will play.

We'll start by allowing the player to choose their role. In NetHack, these are the roles a player can select:

![](figures/role.png)

We will implement all of these. Looking at this list, "data" should immediately come to mind. We're going to create another data file to hold the information for our roles. To start with, we're going to give each role a `name` and a `hotkey`. Create `data/roles.yaml` with the following:

!{code/2_3_role_call_1.yaml}

Now we're going to create a `Role` class that can load all of this data. Create a file named `role.rb` with the following:

!{code/2_3_role_call_2.rb}

We're using for_options here to unify the interface across all of our characteristics, since race and alignment will be dependent on role. We'll see shortly why this abstraction makes sense.

Now we're going to write a generic `SelectionScreen` class. It's job will be to print two messages and display a list of options that can be selected by a hotkey. Create the file `selection_screen.rb` with:

!{code/2_3_role_call_3.rb}

Now let's add some methods one by one. First we'll add our `initialize` and some `attr_reader`s:

!{code/2_3_role_call_4.rb}

When we create a our selection screen we'll call it from `game.rb` with:

!{code/2_3_role_call_5.rb}

So in this case, `trait` will be the class `Role`. On the first line we fetch all the relevant roles by calling `for_options`. If you recall, `for_options` just reads the yaml file of roles and returns all of them. Next we assign the `ui` and `options` variables. Then, we determine a key that we'll use for a couple of things. If `Role` is our trait, then we want `:role` to be our key. Finally, we grab a hash of messages related to our key (:role in this case).

Now we'll implement our only **public** method `render` (make sure this goes above the `private` line):

!{code/2_3_role_call_6.rb}

In this method we check to see if we need to randomly select an item. If we do we don't want to render the screen, so it simply sets the option and returns. Otherwise we'll render the screen. The implementation for `random?` and `random_item` look like this:

!{code/2_3_role_call_7.rb}

For now, `random?` simply checks if `randall` was set and `random_item` just chooses a random element form our items array. Now we can implement `render_screen` and `instructions`:

!{code/2_3_role_call_8.rb}

Here we clear the screen, display the message on the left - "Choosing Role", display the message on the right - "Pick the role of your character", display the choices, and then prompt and handle the player's selection. For convenience, I've pulled out `right_offset` into a method since we'll use it a few times:

!{code/2_3_role_call_9.rb}

This method returns a negative number representing how far left from the right side we should be when printing the right half of our screen.  We'll need to update our `UI` class to handle negative numbers, but let's finish our `SelectionScreen` class first.

Now we'll write our method for rendering our choices

!{code/2_3_role_call_10.rb}

This method is relatively straight forward. We loop through each item and print out the hotkey and the name of the role (we're cheating here by not printing "a" or "an" in front of the name, but it's not really important).

Now let's implement `handle_choice` and `item_for_hotkey`:

!{code/2_3_role_call_11.rb}

Here we have 3 choices. If the user presses "q" then we want to quit. If they press "*" then we want to randomly choose an item. If they press any other valid option we want to assign the corresponding role.

Finally let's implement `prompt` and `hotkeys`:

!{code/2_3_role_call_12.rb}

The `hotkeys` represent our valid choices, but we need to make sure to add "*" and "q" as valid hotkeys.

Now we're ready to initialize this screen in `game.rb`. Add the following constant:

!{code/2_3_role_call_13.rb}

Then change the `run` method to look like this:

!{code/2_3_role_call_14.rb}

And then add `setup_character` and `get_traits` as a private methods:

!{code/2_3_role_call_15.rb}

There are a few things left to do in order to get this working. First, in `main.rb` add:

!{code/2_3_role_call_16.rb}

**Above** the `require "game"` line. Next, we'll need to modify our `UI` class to have a `clear` method. Curses provides this method, but it's private, so we'll need to add the following to `ui.rb`:

!{code/2_3_role_call_17.rb}

While we have the `ui.rb` file open we should handle our `right_offset` issue we described before. Change the implementation of `message` to the following:

!{code/2_3_role_call_18.rb}

Finally, we'll need to add some messages to our `data/messages.yaml` file:

!{code/2_3_role_call_19.yaml}

If you run the program and choose "n" for the first choice then you should see:

![](figures/role_example.png)

Choosing any role will print out the options again, but this time it will display the selected role as well. If you choose "y" at the title screen a random role will appear here. Now that we've laid down the framework for setting traits it should be fairly easy to implement the remaining ones.

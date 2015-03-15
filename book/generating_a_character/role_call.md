## Chapter 3 - Role call

For a game like NetHack, there is a lot of information that goes in to creating a character. From a top level, a character will have a role, race, gender and alignment. Each of these traits will determine how a game session will play.

We'll start by allowing the player to choose their role. In NetHack, these are the roles a player can select:

![selection](images/role.png?raw=true =600x)

We will implement all of these. Looking at this list, "data" should immediately come to mind. We're going to create another data file to hold the information for our roles. To start with, we're going to give each role a `name` and a `hotkey`. Create `data/roles.yaml` with the following:

```yaml
---
- name: Archeologist
  hotkey: a
- name: Barbarian
  hotkey: b
- name: Caveman
  hotkey: d
- name: Healer
  hotkey: h
- name: Knight
  hotkey: k
- name: Monk
  hotkey: m
- name: Priest
  hotkey: p
- name: Rogue
  hotkey: r
- name: Ranger
  hotkey: R
- name: Samurai
  hotkey: s
- name: Tourist
  hotkey: t
- name: Valkyrie
  hotkey: v
- name: Wizard
  hotkey: w
```

Now we're going to create a `Role` class that can load all of this data. Create a file named `role.rb` with the following:

```ruby
class Role
  def self.for_options(_)
    all
  end

  def self.all
    DataLoader.load_file("roles").map do |data|
      new(data)
    end
  end

  attr_reader :name, :hotkey

  def initialize(data)
    data.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def to_s
    name
  end
end
```

We're using for_options here to unify the interface across all of our characteristics, since race and alignment will be dependent on role. We'll see shortly why this abstraction makes sense.

Now we're going to write a generic `SelectionScreen` class. It's job will be to print two messages and display a list of options that can be selected by a hotkey. Create the file `selection_screen.rb` with:

```ruby
class SelectionScreen
end
```

Now let's add some methods one by one. First we'll add our `initialize` and some `attr_reader`s:

```ruby
def initialize(trait, ui, options)
  @items = trait.for_options(options)

  @ui = ui
  @options = options

  @key = trait.name.downcase.to_sym
  @messages = Messages[key]
end

private

attr_reader :items, :ui, :options, :key, :messages
```

When we create a our selection screen we'll call it from `game.rb` with:

```ruby
SelectionScreen.new(Role, ui, options).render
```

So in this case, `trait` will be the class `Role`. On the first line we fetch all the relevant roles by calling `for_options`. If you recall, `for_options` just reads the yaml file of roles and returns all of them. Next we assign the `ui` and `options` variables. Then, we determine a key that we'll use for a couple of things. If `Role` is our trait, then we want `:role` to be our key. Finally, we grab a hash of messages related to our key (:role in this case).

Now we'll implement our only **public** method `render` (make sure this goes above the `private` line):

```ruby
def render
  if random?
    options[key] = random_item
  else
    render_screen
  end
end
```

In this function we check to see if we need to randomly select an item. If we do we don't want to render the screen, so it simply sets the option and returns. Otherwise we'll render the screen. The implementation for `random?` and `random_item` look like this:

```ruby
def random?
  options[:randall]
end

def random_item
  items.sample
end
```

For now, `random?` simply checks if `randall` was set and `random_item` just chooses a random element form our items array. Now we can implement `render_screen` and `instructions`:

```ruby
def render_screen
  ui.clear
  ui.message(0, 0, messages[:choosing])
  ui.message(0, right_offset, instructions)
  render_choices
  handle_choice prompt
end

# instructions has been pulled out into it's own method for a reason
# you will see later

def instructions
  messages[:instructions]
end
```

Here we clear the screen, display the message on the left - "Choosing Role", display the message on the right - "Pick the role of your character", display the choices, and then prompt and handle the player's selection. For convenience, I've pulled out `right_offset` into a method since we'll use it a few times:

```ruby
def right_offset
  @right_offset ||= (instructions.length + 2) * -1
end
```

This method returns a negative number representing how far left from the right side we should be when printing the right half of our screen.  We'll need to update our `UI` class to handle negative numbers, but let's finish our `SelectionScreen` class first.

Now we'll write our method for rendering our choices

```ruby
def render_choices
  items.each_with_index do |item, index|
    ui.message(index + 2, right_offset, "#{item.hotkey} - #{item}")
  end

  ui.message(items.length + 2, right_offset, "* - Random")
  ui.message(items.length + 3, right_offset, "q - Quit")
end
```

This function is relatively straight forward. We loop through each item and print out the hotkey and the name of the role (we're cheating here by not printing "a" or "an" in front of the name, but it's not really important).

Now let's implement `handle_choice` and `item_for_hotkey`:

```ruby
def handle_choice(choice)
  case choice
  when "q" then options[:quit] = true
  when "*" then options[key] = random_item
  else options[key] = item_for_hotkey(choice)
end

def item_for_hotkey(hotkey)
  items.find { |item| item.hotkey == hotkey }
end
```

Here we have 3 choices. If the user presses "q" then we want to quit. If they press "*" then we want to randomly choose an item. If they press any other valid option we want to assign the corresponding role.

Finally let's implement `prompt` and `hotkeys`:

```ruby
def prompt
  ui.choice_prompt(items.length + 4, right_offset, "(end)", hotkeys)
end

def hotkeys
  items.map(&:hotkey).join + "*q"
end
```

The `hotkeys` represent our valid choices, but we need to make sure to add "*" and "q" as valid hotkeys.

Now we're ready to initialize this screen in `game.rb`. Add the following constant:

```ruby
TRAITS = [Role]
```

Then change the `run` function to look like this:

```ruby
def run
  title_screen
  setup_character
end
```

And then add `setup_character` and `get_traits` as a private methods:

```ruby
def setup_character
  get_traits
end

def get_traits
  TRAITS.each do |trait|
    SelectionScreen.new(trait, ui, options).render
    quit?
  end
end
```

There are a few things left to do in order to get this working. First, in `main.rb` add:

```ruby
require "role"
require "selection_screen"
```

**Above** the `require "game"` line. Next, we'll need to modify our `UI` class to have a clear function. Curses provides this function, but it's private, so we'll need to add the following to `ui.rb`:

```ruby
def clear
  super # call curses's clear method
end
```

While we have the `ui.rb` file open we should handle our `right_offset` issue we described before. Change the implementation of `message` to the following:

```ruby
def message(x, y, string)
  x = x + cols if x < 0
  y = y + lines if y < 0

  setpos(y, x)
  addstr(string)
end
```

Finally, we'll need to add some messages to our `data/messages.yaml` file:

```yaml
role:
  choosing: Choosing Role
  instructions: Pick a role for your character
```

If you run the program and choose "n" for the first choice then you should see:

![role selection example](images/role_example.png?raw=true =600x)

Choosing any role will print out the options again, but this time it will display the selected role as well. If you choose "y" at the title screen a random role will appear here. Now that we've laid down the framework for setting traits it should be fairly easy to implement the remaining ones.

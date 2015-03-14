## Chapter 4 - Off to the races

![selection](images/race.png?raw=true =600x)

In our NetHack implementation, race will determine which alignments we can choose as well as some starting stat bonuses. Race will also determine your starting alignment. Dwarves are lawful, gnomes are neutral, elves and orcs are chaotic, and humans can be any alignment (but this may be restricted by the role chosen e.g. samurai are lawful). In terms of stats, dwarves are typically stronger, gnomes and elves are generally smarter, and humans are generally balanced across the stats.

We'll start implementing race by creating a `data/races.yaml` file and filling it in with the following:

```yaml
---
- name: human
  hotkey: h
- name: dwarf
  hotkey: d
- name: gnome
  hotkey: g
- name: orc
  hotkey: o
- name: elf
  hotkey: e
```

Now let's add a `race.rb` file for loading up our races:

```ruby
class Race
  def self.for_options(options)
    role = options[:role]

    all.select { |race| role.races.include? race.hotkey
  end

  def self.all
    DataLoader.load_file("races").map do |data|
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

Here we wan't to limit the selectable races to those allowed by the role. We'll need to modify our existing `data/roles.yaml` to specify which races can be selected for each role. You'll want to add `races` as a key to each role like so

```yaml
- name: Archeologist
  hotkey: a
  races: hdg
```

The race values for the roles are as follows:

* Archeologist: hdg
* Barbarian: ho
* Caveman: hdg
* Healer: hg
* Knight: h
* Monk: h
* Priest: he
* Rogue: ho
* Ranger: hego
* Samurai: h
* Tourist: h
* Valkyrie: hd
* Wizard: hego

In terms of data, we'll also need to add the `:choosing` and `:instructions` messages for `:race`. Open `data/messages.yaml` and add the following:

```yaml
race:
  choosing: Choosing Race
  instructions: Pick the race of your %role
```

We'll be using `%role` as a placeholder for the actual role text. In order to make this work, we'll need to change `instructions` in `selection_screen.rb` to:

```ruby
def instructions
  @instructions ||= interpolate(messages[:instructions])
end
```

and then add the `interpolate` method:

```ruby
def interpolate(message)
  message.gsub(/%(\w+)/) { options[$1.to_sym] }
end
```

To wrap this up we'll want to update the `attr_reader` in `role.rb` to include `:races`. Then we'll also need to change `TRAITS` in `game.rb` to include `Race` **after** `Role`. Finally add a `require` for `race` in `main.rb` before the `require` for `game`.

Now when we run the program we can select the race after the role. However there is one small annoyance. When there is only one possible race, the game should select it for us. An easy way to solve this problem is to change `random?` in our selection_screen class to:

```ruby
def random?
  options[:randall] || items.length == 1
end
```

That way if there is only one element in the array, we'll randomly select it.

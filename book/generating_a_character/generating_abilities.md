## Chapter 7 - Generating Abilities

So once a player has chosen their role, race, gender, and alignment, we'll need to calculate their character's base abilities. In NetHack you have values, ranging between 3 and 25, for strength, wisdom, intelligence, dexterity, charisma, and constitution. We will allocate a total of 75 points to these abilities. Based on a player's role, we'll allocate a specific amount of those points to each ability. The leftover points are then allocated randomly according to rules set by the player's selected role.

Let's briefly go over each stat and how it should affect the game.

Strength will determine how much weight we can handle in our inventory. It will also determine how much melee damage we do as well as how far we can throw things. In NetHack, there are a number of other things that strength affects but we will ignore those for the purpose of out implementation. For display, stength is a bit odd because for a value between 18 and 19 it is shown as a percentage. A value of 18/35 would mean that you are 35% of the way between 18 and 19.

Dexterity will determine your chance of hitting monsters, either by melee combat, missles, or spells.

Constitution increases your healing rate and also attributes to how much weight you can carry. This is useful for roles with low strength like Tourist.

Intelligence is used for reading books and spellcasting for roles other than healers, knights, monks, priests, and valkyries.

Wisdom is used for spellcasting for healers, knights, monks, priests, and valkyries. It also determines how fast your power regenerates and how much power you gain when levelling up.

Charisma is used for getting better prices in shops.

Now for each role there's a specific assignment of points. We're going to add starting attributes to `data/roles.yaml` an entry would look something like this:

```yaml
- name: Archeologist
  hotkey: a
  races: hdg
  genders: mf
  alignments: ln
  starting_attributes:
    strength: 7
    intelligence: 10
    wisdom: 10
    dexterity: 7
    constitution: 7
    charisma: 7
```

Add all the starting attributes according to this chart:

                    strength  intelligence  wisdom  dexterity  constitution  charisma
    Archeologist  7         10            10      7          7             7
    Barbarian     16        7             7       15         16            6
    Caveman       10        7             7       7          8             6
    Healer        7         7             13      7          11            16
    Knight        13        7             14      8          10            17
    Monk          10        7             8       8          7             7
    Priest        7         7             10      7          7             7
    Rogue         7         7             7       10         7             6
    Ranger        13        13            13      9          13            7
    Samurai       10        8             7       10         17            6
    Tourist       7         10            6       7          7             10
    Valkyrie      10        7             7       7          10            7
    Wizard        7         10            7       7          7             7

With the role abilities set we now need to distribute the remaining points. In order to do this we'll need to define for each role the probability that a point will be assigned to that ability. This is different for each class, so for each role we'll add the correct probability - much like we did with the `starting_attributes`. Here is an example of what you'd add after `starting_probabilities`:

```yaml
attribute_probabilities:
  strength: 20
  intelligence: 20
  wisdom: 20
  dexterity: 10
  constitution: 20
  charisma: 10
```

Add all the attribute probabilities in `data/roles.yaml` according to the following chart:

                    strength  intelligence  wisdom  dexterity  constitution  charisma
    Archeologist  20%       20%           20%     10%        20%           10%
    Barbarian     30%       6%            7%      20%        30%           7%
    Caveman       30%       6%            7%      20%        30%           7%
    Healer        15%       20%           20%     15%        25%           5%
    Knight        30%       15%           15%     10%        20%           10%
    Monk          25%       10%           20%     20%        15%           10%
    Priest        15%       10%           30%     15%        20%           10%
    Rogue         20%       10%           10%     30%        20%           10%
    Ranger        30%       10%           10%     20%        20%           10%
    Samurai       30%       10%           8%      30%        14%           8%
    Tourist       15%       10%           10%     15%        30%           20%
    Valkyrie      30%       6%            7%      20%        30%           7%
    Wizard        10%       30%           10%     20%        20%           10%

Now we're ready to create a player class. Add `player.rb` with the following:

```ruby
class Player
  attr_reader :role, :race, :gender, :alignment, :attributes

  def initialize(options)
    @role = options[:role]
    @race = options[:race]
    @gender = options[:gender]
    @alignment = options[:alignment]

    @attributes = AttributeGenerator.new(role).attributes
  end
end
```

And now for the `AttributeGenerator`. With the `AttributeGenerator` we need to make sure we distribute the points according to the probabilities we've defined in our `roles.yaml` file. One way to solve this problem is to generate a number between 0 and 99 and then for each attribute subtract the probability from that number. Once we are less than or equal to zero we choose that attribute. In essence what we're doing is mapping the attributes on a number line and then randomly choosing a number from that line. Whichever attribute our number falls in is the one we want:

![Attribute Assignment Example](images/attribute_assignment.png)

Now we can implement the `AttributeGenerator` according to this algorithm:

```ruby
class AttributeGenerator
  def initialize(role, total = 75)
    @role = role
    @base_attributes = role.starting_attributes.dup
    @total = total
  end

  def attributes
    @attributes ||= assign_remaining_points
  end

  private

  attr_reader :role, :base_attributes, :total

  def remaining_points
    total - base_attributes.values.reduce(:+)
  end

  def assign_remaining_points
    remaining_points.times do
      increment_random_attribute
    end
    
    base_attributes
  end

  def increment_random_attribute
    base_attributes[next_random_attribute] += 1
  end

  def next_random_attribute
    x = rand(100)

    base_attributes.keys.find do |key|
      (x -= role.attribute_probabilities[key]) <= 0
    end
  end
end
```

Make sure you have `:starting_attributes` and `attribute_probabilities` as `attr_readers` in `Role`. Also add `require`s for `Player` and `AttributeGenerator` to `main.rb`. Now in `game.rb` we can instantiate our player:

```ruby
def setup_character
  get_traits
  options[:player] = make_player
end

def make_player  
  Player.new(options).tap do
    %i(role race gender alignment).each { |key| options.delete(key) }
  end
end
```

Now for the last set of attributes we'll want to assign hitpoints and power. These operate a little differently because you need to store the current amount you have as well as your maximum. Hitpoints are determined by adding together your role's hitpoints and your race's hitpoints. Your power is determined by adding your role's power plus some random number (usually zero) and your race's power. In `roles.yaml` and `races.yaml` add `hitpoints` and `power` and `rand_power` according to the following charts:

                 hitpoints  power  rand_power
    Acheologist  11         1      0
    Barbarian    14         1      0
    Caveman      14         1      0
    Healer       11         1      4
    Knight       14         1      4
    Monk         12         2      2
    Priest       12         4      3
    Rogue        10         1      0
    Ranger       13         1      0
    Samurai      13         1      0
    Tourist      8          1      0
    Valkyrie     14         1      0
    Wizard       10         4      3

***

           hitpoints  power
    Human  2          1
    Dwarf  4          0
    Gnome  1          2
    Orc    1          1
    Elf    1          2

Once you've added `attr_accessor`s for `hitpoints` and `power` in both `Role` and `Race` as well as `rand_power` in `Race` you just have to add the following to your `Player` `initialize` method:

```ruby
@hitpoints = role.hitpoints + race.hitpoints
@max_hitpoints = hitpoints
@power = role.power + rand(role.rand_power + 1) + race.power
@max_power = power
```

And then add `attr_accessors` for `hitpoints`, `max_hitpoints`, `power`, and `max_power`. There are plenty of other things we could add to our characters at this point, but this is enough to move us onward to the challenge of procedurally generated dungeons.

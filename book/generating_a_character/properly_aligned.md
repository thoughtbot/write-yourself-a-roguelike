## Chapter 6 - Properly aligned

![selection](images/alignment.png?raw=true =600x)

Now for the final trait.  Alignment determines how the actions you take in game will affect you. If you do things that contrast your alignment your god will be angry with you and the game will become more difficult.

First let's follow suit and create a `data/alignments.yaml` file with the following:

    ---
    - name: lawful
      hotkey: l
    - name: neutral
      hotkey: n
    - name: chaotic
      hotkey: c

The alignments you are allowed to choose from depend on your race and role. If your role is anything other than human, your alignment is predetermined, whereas humans can choose any alignment available to the role. So for each race we need to add an `alignments` key to `data/races.yaml` with the following values:

* Human: lnc
* Dwarf: l
* Gnome: n
* Orc: c
* Elf: c

You'll need to do the same thing in `data/roles.yaml`:

* Archeologist: ln
* Barbarian: nc
* Caveman ln
* Healer: n
* Knight: l
* Monk: lnc
* Priest: lnc
* Rogue: c
* Ranger: nc
* Samurai: l
* Tourist: n
* Valkyrie: ln
* Wizard: nc

To finish off editing our data let's add the following to the end of `data/messages.yaml`:

    alignment:
      choosing: Choosing Alignment
      instructions: Pick the alignment of your %gender %race %role

Now since our available alignments depend on both our role and our race we'll need to create the following `alignment.rb`:

    class Alignment
      def self.for_options(options)
        role = options[:role]
        race = options[:race]
        possible = role.alignments.chars & race.alignments.chars

        all.select { |alignment| possible.include? alignment.hotkey }
      end

      def self.all
        DataLoader.load_file("alignments").map do |data|
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

Finally you'll want to add `Alignment` to the end of `TRAITS` in `game.rb`, add the appropriate require before requiring `game` in `main.rb`, and add `:alignments` as an `attr_reader` to `Role` and `Race`.

Running the program now you should see it output all of chosen traits.


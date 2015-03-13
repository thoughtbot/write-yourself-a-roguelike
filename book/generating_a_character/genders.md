## Chapter 5 - Genders

![selection](images/gender.png?raw=true =600x)

For our purposes, gender will determine which pronoun your character will be addressed with. In actual NetHack gender does affect some interactions in the game, but we won't be going that in depth with our implementation.

We're going to follow the same pattern for genders as we did with roles and races. First create a `data/genders.yaml` file with the following:

```yaml
---
- name: male
  hotkey: m
- name: female
  hotkey: f
```

Valkyries are the only role that cannot choose between both genders. All Valkyries are female. Rather than making an exception, we'll implement this in the same manner we handled race by specifying which gender you can choose in our role file. For each of the roles aside from Valkyrie add:

```yaml
genders: mf
```

For Valkyrie add:

```yaml
genders: f
```

Now add `:genders` to the list of `attr_reader`s in `role.rb` and create a `gender.rb` with the following:

```ruby
class Gender
  def self.for_options(options)
    role = options[:role]
    all.select { |gender| role.genders.include? gender.hotkey }
  end

  def self.all
    DataLoader.load_file("genders").map do |data|
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

Then once again we'll need to change `data/messages.yaml` to include the `:gender` messages

```yaml
gender:
  choosing: Choosing Gender
  instructions: Pick the gender of your %race %role
```

Finally you'll want to add `Gender` to the end of `TRAITS` in `game.rb` and add `gender` to the list of requires before `game`.

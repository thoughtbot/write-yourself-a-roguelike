## Chapter 2 - Messages

There are going to be a lot of in-game messages and to make things more fluid we should extact them into a yaml file. This makes them far easier to change (or to internationalize) later. Let's start by creating a `data` directory. This directory will hold some yaml files that will contain in game text and other data. In that directory, let's create a file for holding our in-game messages. Name the file `messages.yaml` and add the following to it:

```yaml
---
title:
  name: Rhack, a NetHack clone
  by: by a daring developer
  pick_random: "Shall I pick a character's race, role, gender and alignment for you? [ynq]"
```

Next, we'll want to update our `TitleScreen` class to make use of these messages. In order to do that, we'll first need some way to load the yaml file. In this situation, it's a good idea to isolate an external dependency like YAML in order to make it easier to replace or modify in the future. We took this exact approach with Curses by extracting the UI into its own class. Let's extract a `DataLoader` class that knows how to load our data for us. Create a `data_loader.rb` file with the following:

```ruby
class DataLoader
  def self.load_file(file)
    new.load_file(file)
  end

  def load_file(file)
    symbolize_keys YAML.load_file("data/#{file}.yaml")
  end

  private

  def symbolize_keys(object)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), hash|
        hash[key.to_sym] = symbolize_keys(value)
      end
    when Array
      object.map { |element| symbolize_keys(element) }
    else
      object
    end
  end
end
```

The reason behind `symbolize_keys` is that YAML will parse all the keys as strings and I prefer symbols for this. Even though `ActiveSupport` has a similar method, we're going to leave it out because it won't work directly with arrays. Our implementation will symbolize the keys correctly for hashes or arrays even if they are nested.

Now we'll create a global way to access these messages. Create a file called `messages.rb` with the following:

```ruby
module Messages
  def self.messages
    @messages ||= DataLoader.load_file("messages")
  end

  def self.[](key)
    messages[key]
  end
end
```

It's evident here that our Messages module knows nothing about the YAML backend, instead it simply asks our DataLoader to load the messages. Now that we have a way to get our messages let's change our `title_screen.rb` to make use of it. In initialize add the following:

```ruby
@messages = Messages[:title]
```

Make sure to add `:messages` to the `attr_reader` line, like so:

```ruby
attr_reader :ui, :options, :messages
```

and then change `render` to the following:

```ruby
def render
  ui.message(0, 0, messages[:name])
  ui.message(1, 7, messages[:by])
  handle_choice prompt
end
```

And change `prompt` to:

```ruby
def prompt
  ui.choice_prompt(3, 0, messages[:pick_random], "ynq")
end
```

Now to finish up, add `require`s in `main.rb` for `yaml`, `data_loader`, and `messages`. When you run the program again it should still function like our previous implementation.

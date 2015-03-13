class SelectionScreen
  def initialize(trait, ui, options)
    @items = trait.for_options(options)

    @ui = ui
    @options = options

    @key = trait.name.downcase.to_sym
    @messages = Messages[key]
  end

  def render
    if random?
      options[key] = random_item
    else
      render_screen
    end
  end

  private

  attr_reader :items, :ui, :options, :key, :messages

  def random?
    options[:randall] || items.length == 1
  end

  def random_item
    items.sample
  end

  def render_screen
    ui.clear
    ui.message(0, 0, messages[:choosing])
    ui.message(right_offset, 0, instructions)
    render_choices
    handle_choice prompt
  end

  def instructions
    @instructions ||= interpolate(messages[:instructions])
  end

  def interpolate(message)
    message.gsub(/%(\w+)/) { options[$1.to_sym] }
  end

  def right_offset
    @right_offset ||= (instructions.length + 2) * -1
  end

  def render_choices
    items.each_with_index do |item, index|
      ui.message(right_offset, index + 2, "#{item.hotkey} - #{item}")
    end

    ui.message(right_offset, items.length + 2, "* - Random")
    ui.message(right_offset, items.length + 3, "q - Quit")
  end

  def handle_choice(choice)
    case choice
    when "q" then options[:quit] = true
    when "*" then options[key] = random_item
    else options[key] = item_for_hotkey(choice)
    end
  end

  def item_for_hotkey(hotkey)
    items.find { |item| item.hotkey == hotkey }
  end

  def prompt
    ui.choice_prompt(right_offset, items.length + 4, "(end)", hotkeys)
  end

  def hotkeys
    items.map(&:hotkey).join + "*q"
  end
end

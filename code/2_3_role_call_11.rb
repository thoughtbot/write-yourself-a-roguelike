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

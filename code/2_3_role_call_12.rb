def prompt
  ui.choice_prompt(items.length + 4, right_offset, "(end)", hotkeys)
end

def hotkeys
  items.map(&:hotkey).join + "*q"
end

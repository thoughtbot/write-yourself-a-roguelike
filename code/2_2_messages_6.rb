def render
  ui.message(0, 0, messages[:name])
  ui.message(1, 7, messages[:by])
  handle_choice prompt
end

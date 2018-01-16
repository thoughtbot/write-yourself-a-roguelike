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

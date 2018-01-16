def render_choices
  items.each_with_index do |item, index|
    ui.message(index + 2, right_offset, "#{item.hotkey} - #{item}")
  end

  ui.message(items.length + 2, right_offset, "* - Random")
  ui.message(items.length + 3, right_offset, "q - Quit")
end

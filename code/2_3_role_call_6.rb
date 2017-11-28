def render
  if random?
    options[key] = random_item
  else
    render_screen
  end
end

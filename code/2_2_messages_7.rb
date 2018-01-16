def prompt
  ui.choice_prompt(3, 0, messages[:pick_random], "ynq")
end

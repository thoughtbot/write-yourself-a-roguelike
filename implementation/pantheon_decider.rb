require "yaml"
require "pantheon"

class PantheonDecider
  include Curses
  PANTHEON_FILE = "data/pantheons.yaml"

  def initialize(role)
    @role = role
    @pantheons = YAML.load_file(PANTHEON_FILE).each_with_object({}) do |(role, pantheon), hash|
      hash[role] = Pantheon.from_yaml(pantheon)
    end
  end

  def pantheon
    @pantheons.fetch(@role.masculine) { @pantheons.values.sample }
  end
end

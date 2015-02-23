require "god"

class Pantheon
  def self.from_yaml(yaml)
    new(yaml)
  end

  def initialize(gods)
    @gods = gods.each_with_object({}) do |(alignment, god), hash|
      hash[alignment] = God.from_yaml(god)
    end
  end

  def god_for(alignment)
    @gods[alignment.name]
  end
end

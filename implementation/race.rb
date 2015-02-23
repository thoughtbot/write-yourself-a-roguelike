class Race
  def self.from_yaml(yaml)
    new(yaml["name"],
        yaml["alignments"],
        yaml["hitpoints"],
        yaml["energy"]
       )
  end

  attr_reader :name, :alignments
  attr_reader :hitpoints, :energy

  def initialize(name, alignments, hitpoints, energy)
    @name = name
    @alignments = alignments
    @hitpoints = hitpoints.each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value
    end

    @energy = energy.each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value
    end
  end
end

class Role
  def self.from_yaml(yaml)
    new(yaml["name"],
        yaml["races"],
        yaml["alignments"],
        yaml["ranks"],
        yaml["starting_attributes"],
        yaml["remaining_point_probabilities"],
        yaml["hitpoints"],
        yaml["energy"])
  end

  attr_reader :name, :race_choices, :alignments
  attr_reader :strength, :wisdom, :intelligence, :constitution, :charisma, :dexterity
  attr_reader :hitpoints, :energy, :remaining_point_probabilities

  def initialize(name, race_choices, alignments, ranks, starting_attributes, remaining_point_probabilities, hitpoints, energy)
    @name = name
    @race_choices = race_choices
    @alignments = alignments
    @ranks = ranks
    starting_attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @remaining_point_probabilities = remaining_point_probabilities.each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value
    end

    @hitpoints = hitpoints.each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value
    end

    @energy = energy.each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value
    end
  end

  def masculine
    @name[0]
  end

  def feminine
    @name[1] || @name[0]
  end

  def rank_for(level)
    if level <= 2
      @ranks[0]
    elsif level <= 30
      @ranks[(level + 2) / 4]
    else
      @ranks[8]
    end
  end

  def to_s
    @name.join("/")
  end
end

class Role
  def self.from_yaml(yaml)
    new(yaml["name"], yaml["races"], yaml["alignments"])
  end

  attr_reader :name, :race_choices, :alignments

  def initialize(name, race_choices, alignments)
    @name = name
    @race_choices = race_choices
    @alignments = alignments
  end

  def masculine
    @name[0]
  end

  def feminine
    @name[1] || @name[0]
  end

  def to_s
    @name.join("/")
  end
end

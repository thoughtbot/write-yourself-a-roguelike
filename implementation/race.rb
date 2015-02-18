class Race
  def self.from_yaml(yaml)
    new(yaml["name"], yaml["alignments"])
  end

  attr_reader :name, :alignments

  def initialize(name, alignments)
    @name = name
    @alignments = alignments
  end
end

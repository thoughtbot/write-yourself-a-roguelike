class God
  def self.from_yaml(yaml)
    new(yaml["name"], yaml["gender"])
  end

  attr_reader :name

  def initialize(name, gender)
    @name = name
    @gender = gender
  end

  def title
    @gender == "f" ? "goddess" : "god"
  end
end

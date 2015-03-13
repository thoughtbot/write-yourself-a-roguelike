class Race
  def self.for_options(options)
    role = options[:role]

    all.select { |race| role.races.include? race.hotkey }
  end

  def self.all
    DataLoader.load_file("races").map do |data|
      new(data)
    end
  end

  attr_reader :name, :hotkey, :alignments
  attr_reader :hitpoints, :power

  def initialize(data)
    data.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def to_s
    name
  end
end

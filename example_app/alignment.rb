class Alignment
  def self.for_options(options)
    role = options[:role]
    race = options[:race]
    possible = role.alignments.chars & race.alignments.chars

    all.select { |alignment| possible.include? alignment.hotkey }
  end

  def self.all
    DataLoader.load_file("alignments").map do |data|
      new(data)
    end
  end

  attr_reader :name, :hotkey

  def initialize(data)
    data.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def to_s
    name
  end
end

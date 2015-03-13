class Gender
  def self.for_options(options)
    role = options[:role]

    all.select { |gender| role.genders.include? gender.hotkey }
  end

  def self.all
    DataLoader.load_file("genders").map do |data|
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

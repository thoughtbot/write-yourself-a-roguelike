class DataLoader
  def self.load_file(file)
    new.load_file(file)
  end

  def load_file(file)
    symbolize_keys YAML.load_file("data/#{file}.yaml")
  end

  private

  def symbolize_keys(object)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), hash|
        hash[key.to_sym] = symbolize_keys(value)
      end
    when Array
      object.map { |element| symbolize_keys(element) }
    else
      object
    end
  end
end

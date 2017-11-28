class AttributeGenerator
  def initialize(role, total = 75)
    @role = role
    @base_attributes = role.starting_attributes.dup
    @total = total
  end

  def attributes
    @attributes ||= assign_remaining_points
  end

  private

  attr_reader :role, :base_attributes, :total

  def remaining_points
    total - base_attributes.values.reduce(:+)
  end

  def assign_remaining_points
    remaining_points.times do
      increment_random_attribute
    end

    base_attributes
  end

  def increment_random_attribute
    base_attributes[next_random_attribute] += 1
  end

  def next_random_attribute
    x = rand(100)

    base_attributes.keys.detect do |key|
      (x -= role.attribute_probabilities[key]) <= 0
    end
  end
end

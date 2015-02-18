class Player
  attr_accessor :role, :race, :gender, :alignment

  def initialize
    @role = nil
    @race = nil
    @gender = nil
    @alignment = nil
  end

  def role_name
    case @gender.name
    when "male" then @role.masculine
    when "female" then @role.feminine
    else raise "Invalid gender"
    end
  end
end

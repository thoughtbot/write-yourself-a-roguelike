require "pantheon_decider"

class Player
  attr_accessor :role, :race, :gender, :alignment, :x, :y
  attr_reader :strength, :dexterity, :intelligence, :wisdom, :charisma, :constitution
  attr_reader :current_hp, :max_hp, :current_energy, :max_energy, :dungeon_level
  attr_reader :armor_class, :level, :money

  def initialize
    @role = nil
    @race = nil
    @gender = nil
    @alignment = nil
    @level = 1
    @x = 10
    @y = 10
    @dungeon_level = 1
    @money = 0
    @current_hp = 0
    @max_hp = 0
    @current_energy = 0
    @max_energy = 0
    @armor_class = 10
    @strength = 0
    @dexterity = 0
    @constitution = 0
    @intelligence = 0
    @wisdom = 0
    @charisma = 0
  end

  def name
    @name ||= ENV["USER"][0..9].capitalize
  end

  def rank
    rank_names = @role.rank_for(@level)
    if @gender == "m"
      rank_names[0]
    else
      rank_names[1] || rank_names[0]
    end
  end

  def role=(role)
    @role = role
    @pantheon = PantheonDecider.new(@role).pantheon
  end

  def setup
    @strength = @role.strength
    @intelligence = @role.intelligence
    @wisdom = @role.wisdom
    @constitution = @role.constitution
    @charisma = @role.charisma
    @dexterity = @role.dexterity
    remaining_points = 75 - (@strength + @intelligence + @wisdom + @constitution + @charisma + @dexterity)
    remaining_points.times do
      val = rand(1..100)
      current = @role.remaining_point_probabilities[:strength]
      if val <= current
        @strength += 1
      else
        current += @role.remaining_point_probabilities[:intelligence]

        if val <= current
          @intelligence += 1
        else
          current += @role.remaining_point_probabilities[:wisdom]

          if val <= current
            @wisdom += 1
          else
            current += @role.remaining_point_probabilities[:dexterity]

            if val <= current
              @dexterity += 1
            else
              current += @role.remaining_point_probabilities[:constitution]

              if val <= current
                @constitution += 1
              else
                @charisma += 1
              end
            end
          end
        end
      end
    end
    @max_hp = @role.hitpoints[:base] + @race.hitpoints[:base]
    @current_hp = @max_hp
    @max_energy = @role.energy[:base] + @race.energy[:base]
    @current_energy = @max_energy
  end

  def god
    @pantheon.god_for(@alignment)
  end

  def role_name
    case @gender.name
    when "male" then @role.masculine
    when "female" then @role.feminine
    else raise "Invalid gender"
    end
  end
end

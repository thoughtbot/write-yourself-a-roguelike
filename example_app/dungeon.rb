require "yaml"
require_relative "data_loader"

Rect = Struct.new(:left, :top, :right, :bottom)

class Tileset
  def self.load(name, loader: DataLoader)
    data = loader.load_file("tilesets/#{name}")
    new(data)
  end

  def initialize(tiles)
    @tiles = tiles
  end

  def [](key)
    tiles[key]
  end

  private

  attr_reader :tiles
end

class Dungeon
  attr_reader :rows

  def initialize(width, height, tileset:)
    @tileset = tileset
    @rows = Array.new(height) { Array.new(width) { tileset[:stone] } }
  end

  def build(type, x, y)
    rows[y][x] = tileset[type]
  end

  private

  attr_reader :tileset
end

class RoomGenerator
  MIN_WIDTH = 2
  MIN_HEIGHT = 2
  MAX_WIDTH_MODIFIER = 12
  MAX_HEIGHT_MODIFIER = 4
  MAX_FLOOR_AREA = 50

  def initialize(rect)
    @rect = rect
  end

  def generate
    constrain_floor_area
    build_room
  end

  private

  attr_reader :rect

  def constrain_floor_area
    if floor_area > MAX_FLOOR_AREA
      @width = 50 / height
    end
  end

  def build_room
    Rect.new(left, top, right, bottom)
  end

  def floor_area
    width * height
  end

  def height
    @height ||= MIN_HEIGHT + rand(MAX_HEIGHT_MODIFIER)
  end

  def width
    @width ||= MIN_WIDTH + rand(MAX_WIDTH_MODIFIER)
  end

  def left
    @left ||= rect.left + 1 + rand(rect.right - width - 2)
  end

  def top
    @top ||= rect.top + 1 + rand(rect.bottom - height - 2)
  end

  def right
    @right ||= left + width
  end

  def bottom
    @bottom ||= top + height
  end
end

class DungeonGenerator
  DEFAULT_WIDTH = 80
  DEFAULT_HEIGHT = 21
  DEFAULT_TILESET_NAME = "default"

  def initialize(options = {})
    @options = options
    @dungeon = Dungeon.new(width, height, tileset: tileset)
    @rects = [ Rect.new(0, 0, width, height) ]
  end

  def generate
    room = create_room
    render_room(room)
    dungeon
  end

  private

  attr_reader :dungeon, :rects, :options

  def create_room
    room_generator.new(rects.first).generate
  end

  def render_room(room)
    room_renderer.new(room, dungeon).render
  end

  def room_generator
    options.fetch(:room_generator, RoomGenerator)
  end

  def room_renderer
    options.fetch(:room_renderer, RoomRenderer)
  end

  def width
    options.fetch(:width, DEFAULT_WIDTH)
  end

  def height
    options.fetch(:height, DEFAULT_HEIGHT)
  end

  def tileset
    @_tileset ||= Tileset.load(tileset_name)
  end

  def tileset_name
    options.fetch(:tileset_name, DEFAULT_TILESET_NAME)
  end

  def print_dungeon
    puts dungeon.map(&:join)
  end
end

class DungeonPrinter
  def initialize(dungeon, io = STDOUT)
    @dungeon = dungeon
    @io = io
  end

  def print
    io.puts dungeon.rows.map(&:join)
  end

  private

  attr_reader :io, :dungeon
end

class RoomRenderer
  def initialize(room, dungeon)
    @left = room.left
    @right = room.right
    @top = room.top
    @bottom = room.bottom
    @dungeon = dungeon
  end

  def render
    render_floor
    render_vertical_walls
    render_horizontal_walls
  end

  private

  attr_reader :top, :left, :right, :bottom, :dungeon

  def render_floor
    left.upto(right) do |x|
      top.upto(bottom) do |y|
        dungeon.build(:floor, x, y)
      end
    end
  end

  def render_vertical_walls
    top.upto(bottom) do |y|
      dungeon.build(:vertical_wall, left - 1, y)
      dungeon.build(:vertical_wall, right + 1, y)
    end
  end

  def render_horizontal_walls
    (left - 1).upto(right + 1) do |x|
      dungeon.build(:horizontal_wall, x, top - 1)
      dungeon.build(:horizontal_wall, x, bottom + 1)
    end
  end
end

dungeon = DungeonGenerator.new.generate
DungeonPrinter.new(dungeon).print

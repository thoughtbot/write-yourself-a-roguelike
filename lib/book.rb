require "pandoc-ruby"

class Book
  def initialize
    @release_dir = "release"
    @release_filename = "write-yourself-a-roguelike"
    @tmpdir = Dir.mktmpdir

    FileUtils.cp_r("book", @tmpdir)

    @files = Dir.glob("#{@tmpdir}/book/**/*.md").sort
  end

  def compile
    @files.each do |file|
      insert_code(file)
    end

    convert_to_epub
  end

  def cleanup
    FileUtils.remove_entry @tmpdir
  end

  private

  def convert_to_epub
    data = PandocRuby.new(@files).to_epub(:table_of_contents)
    File.open(release_path("epub"), "w") { |file| file.write(data) }
  end

  def release_path(ext)
    "#{@release_dir}/#{@release_filename}.#{ext}"
  end

  def insert_code(file)
    contents = IO.read(file)

    contents.scan(/!{.*}/).each do |match|
      filename = match.match(/{(.*)}/)[1]
      code = IO.read(filename)
      contents.gsub!(match, "```#{syntax(filename)}\n#{code}```")
      File.open(file, "w") { |f| f.write contents }
    end
  end

  def syntax(filename)
    ext = filename.split(".").last
    case ext
    when "rb"
      "ruby"
    when ->(a) { a == "yaml" || a == "yml" }
      "yaml"
    else
      ""
    end
  end
end

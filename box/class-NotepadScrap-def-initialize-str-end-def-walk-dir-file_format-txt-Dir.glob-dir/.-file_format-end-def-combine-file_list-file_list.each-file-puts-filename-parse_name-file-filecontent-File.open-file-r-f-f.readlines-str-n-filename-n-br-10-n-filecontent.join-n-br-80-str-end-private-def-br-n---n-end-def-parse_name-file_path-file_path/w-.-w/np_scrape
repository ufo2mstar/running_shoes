class NotepadScrap
  def initialize
    @str = ""
  end

  def walk(dir, file_format = "txt")
    Dir.glob("#{dir}/*.#{file_format}")
  end

  def combine(file_list)
    file_list.each { |file|
      puts filename = parse_name(file)
      filecontent = File.open(file, 'r') { |f| f.readlines }
      @str +="\n#{filename}\n#{br(10)}\n#{filecontent.join}\n#{br(80)}"
    }
    @str
  end

  private

  def br n
    "-"*n
  end

  def parse_name file_path
    file_path[/\\|\/(\w+\.\w+)$/, 1]
  end
end

dir = File.dirname(__FILE__)

np = NotepadScrap.new
files = np.walk dir
puts np.combine files

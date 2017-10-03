class WowsReplay
  attr_reader(:filename, :version)

  def initialize(filename)
    @filename = filename
    @version = File.open(filename, 'r') do |f|
      line = f.gets
      
      unless line.nil?
        c = /.*?"clientVersionFromExe": "(\d+), (\d+), (\d+), .*?".*?/.match(line).captures 
        WowsVersion.new(c[0], c[1], c[2])
      end
    end
  end
  
  def rename
    if needs_renaming?
      i = @filename.index '.wowsreplay'
      changed = String::new(@filename).insert(i, " #{@version.format}")
      File.rename(@filename, changed)
      puts "#{@filename} renamed to #{changed}"
    end
  end
  
  def wows_file?
    !@version.nil?
  end
  
  def needs_renaming?
    unless !wows_file?
      !@filename.include? @version.format
    end
  end
end

class WowsVersion
  def initialize(major, minor, build)
    @major, @minor, @build = major, minor, build
  end
  
  def format
    "#{@major}.#{@minor}.#{@build}"
  end
end

Dir.glob('./*.wowsreplay') do |fn|
  w = WowsReplay.new fn
  
  if w.wows_file?
    w.rename
  end
end
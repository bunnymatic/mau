class ScssFileReader

  def initialize(file)
    @scss_file = file
  end

  def parse_colors
    c = (File.open(@scss_file, 'r').map do |line|
      if /\$(.*)\:\s*\#(.*)\;/.match(line.strip)
        [$1, $2]
      end
    end)
    c.compact
  end
end

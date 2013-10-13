class ScssFileReader

  def initialize(file)
    @scss_file = file
  end

  def parse_colors
    css_data = []
    File.open(@css_file, 'r').each do |line|
      if /\$(.*)\:\s*\#(.*)\;/.match(line.strip)
        css_data << [$1, $2]
      end
    end
    css_data
  end
end

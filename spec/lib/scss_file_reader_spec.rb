describe ScssFileReader do

  it 'parses colors from a scss file' do
    mock_scss = StringIO.new(%Q{
     /* whatever */
        $black: #000;
        $white: #ffffff;
        $red: #ff0000;
        $yellr: #fc2; 
      @mixin this = that
      .style { overflow:hidden; }

      // empty line and comment line
    })
    File.stub(:open => mock_scss)
    colors = ScssFileReader.new('f').parse_colors
    expect(colors).to eql([['black', '000'],
                           ['white', 'ffffff'],
                           ['red','ff0000'],
                           ['yellr','fc2']])
  end
end

require 'rails_helper'
describe ScssColorReader do

  let(:color_scss_file) { fixture_file('files/test_colors.scss') }

  it 'parses colors from a scss file' do
    colors = described_class.new(color_scss_file).parse_colors
    expect(colors).to eql([['black', '000'],
                           ['white', 'ffffff'],
                           ['red','ff0000'],
                           ['yellr','fc2'],
                           ["light_yellr", "ffe488"],
                           ["dark_yellr", "eeb700"]])
  end
end

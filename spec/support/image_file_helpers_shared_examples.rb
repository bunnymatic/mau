# frozen_string_literal: true
shared_examples_for ImageFileHelpers do
  describe 'clean_filename' do
    [['fname.jpg', 'fname.jpg'],
     ['f & name.jpg', 'fname.jpg'],
     ['f & *#q45sd  name.jpg', 'fq45sdname.jpg'],
     ['fname .jpg', 'fname.jpg']].each do |f|
      it "cleans #{f[0]} to #{f[1]}" do
        expect(described_class.clean_filename(f[0])).to eql f[1]
      end
    end
  end

  describe 'create_timestamped_filename' do
    before do
      t = Time.zone.now
      allow(Time.zone).to receive(:now).and_return(t)
    end

    it 'builds a timestamped filename given an input filename' do
      fname = described_class.create_timestamped_filename('/a/b/c/whatever.jpg')
      expect(fname).to eql([Time.zone.now.to_i.to_s, 'whatever.jpg'].join)
    end
  end
  describe 'get_file_extension' do
    ['a.jpg', 'a .jpg', 'this.jpg.html.haml.jpg'].each do |jpg_file|
      it "returns jpg for #{jpg_file}" do
        expect(described_class.get_file_extension(jpg_file)).to eql 'jpg'
      end
    end

    it 'returns pdf for whatever.pdf' do
      expect(described_class.get_file_extension('whatever.pdf')).to eql 'pdf'
    end

    it 'raises when there is no .' do
      expect { described_class.get_file_extension('pdf') }.to raise_error(ArgumentError)
    end

    it 'raises when there is no extension' do
      expect { described_class.get_file_extension('pdf.') }.to raise_error(ArgumentError)
    end
  end
end

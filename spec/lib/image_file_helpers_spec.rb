require 'spec_helper'

describe ImageFileHelpers, :type => :helper do
  describe 'clean_filename' do
    [['fname.jpg', 'fname.jpg'],
     ['f & name.jpg', 'fname.jpg'],
     ['f & *#q45sd  name.jpg', 'fq45sdname.jpg'],
     ['fname .jpg', 'fname.jpg']].each do |f|
      it "cleans #{f[0]} to #{f[1]}" do
        (helper.clean_filename f[0]).should eql f[1]
      end
    end
  end
end

require 'spec_helper'

describe ProfileImage do

  let(:artist) { FactoryGirl.create(:artist) }
  let(:studio) { FactoryGirl.create(:studio) }
  let(:object) { studio }

  subject(:profile_image) { ProfileImage.new(object) }

  its(:dir_prefix) { should eql "studiodata" }
  its(:dir) { should eql 'public/studiodata/%d/profile' % studio.id }

  context 'for an artist' do
    let(:object) { artist }
    its(:dir_prefix) { should eql "artistdata" }
    its(:dir) { should eql 'public/artistdata/%d/profile' % artist.id }
  end
end

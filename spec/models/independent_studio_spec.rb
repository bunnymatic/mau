require 'spec_helper'

describe IndependentStudio do

  its(:id) { should eq 0 }
  its(:name) { should eq "Independent Studios" }
  its(:url) { should be_nil }
  its(:get_profile_image) { should match 'independent-studios.jpg' }

  it "to_json is pre-keyed by 'studio'" do
    JSON.parse(IndependentStudio.new.to_json).should have_key "studio"
  end

end

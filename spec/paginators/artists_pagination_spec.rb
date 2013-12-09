require 'spec_helper'

describe ArtistsPagination do

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) { Artist.active.all }
  
  subject(:paginator) { ArtistPagination.new(mock_view_context, artists, current_page, per_page) }

  its(:previous_link) { should eql artists_path(:p => 0) }
  its(:next_link) { should eql artists_path(:p => 2) }
  its(:first_link) { should eql artists_path(:p => 0) }
  its(:last_link) { should eql artists_path(:p => 2) }

end

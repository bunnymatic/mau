require 'spec_helper'

describe ArtistsPagination do

  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) { FactoryGirl.build_list(:user, 9) }

  subject(:paginator) { ArtistsPagination.new(mock_view_context, artists, current_page, per_page) }

  its(:previous_link) { should eql mock_view_context.artists_path(:p => 0) }
  its(:next_link) { should eql mock_view_context.artists_path(:p => 2) }
  its(:first_link) { should eql mock_view_context.artists_path(:p => 0) }
  its(:last_link) { should eql mock_view_context.artists_path(:p => (artists.length/2)) }

end

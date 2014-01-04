require 'spec_helper'

describe ArtistsPresenter do

  include PresenterSpecHelpers

  fixtures :users, :roles_users,  :roles, :artist_infos, :art_pieces,
    :studios, :media, :art_piece_tags, :art_pieces_tags, :cms_documents

  let(:os_only) { false }

  subject(:presenter) { ArtistsPresenter.new(mock_view_context, os_only) }

  its('artists.to_a') { should eql Artist.active.sort_by(&:sortable_name).to_a }

  context 'os_only is true' do
    let(:os_only) { true }
    let(:os_participants) { Artist.active.open_studios_participants }
    its('artists.to_a') { should eql os_participants.reject{|a| !a.in_the_mission? }.sort_by(&:sortable_name).to_a }

  end

end

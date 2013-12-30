require 'spec_helper'

describe CatalogPresenter do

  include MarkdownUtils

  fixtures :cms_documents, :users, :artist_infos, :roles, :studios, :art_pieces,:media, :art_pieces_tags

  let(:reception_doc) { cms_documents(:os_preview_reception) }

  its("all_artists.all") { should eql Artist.active.open_studios_participants.all }
  its(:indy_artists) { should eql Artist.active.open_studios_participants.reject(&:in_a_group_studio?) }
  its(:indy_artists_count) { should eql Artist.active.open_studios_participants.reject(&:in_a_group_studio?).count }
  its(:group_studio_artists) { should eql Artist.active.open_studios_participants.select(&:in_a_group_studio?) }
  its(:preview_reception_data) do
    should eql({
      "data-page" => reception_doc.page,
      "data-section" => reception_doc.section,
      "data-cmsid" => reception_doc.id
    })
  end
  its(:preview_reception_content) { should eql markdown(reception_doc.article) }
  it 'sorts artists by name within their studio' do
    subject.artists_by_studio.each do |studio, artists|
      expect(artists.map{|a| a.lastname.downcase}).to be_monotonically_increasing
    end
  end

end

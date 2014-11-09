require 'spec_helper'

describe CatalogPresenter do
  let!(:open_studios_event) { FactoryGirl.create :open_studios_event }
  let!(:artists) { FactoryGirl.create_list :artist, 4, :with_studio }
  let(:reception_doc) {
      FactoryGirl.create(:cms_document,
                         page: "main_openstudios",
                         section: "preview_reception",
                         article: "# pr header\n\n## pr header2\n\ncome out to the *preview* receiption")
  }

  before do
    artists[0..1].each do |artist|
      artist.update_os_participation open_studios_event.key, true
    end
  end

  its(:csv_filename) { should eql "mau_catalog_#{open_studios_event.key}.csv" }
  its("all_artists.all.sort") {
    should eql Artist.active.open_studios_participants.all.sort
  }
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
  its(:preview_reception_content) { should eql MarkdownService.markdown(reception_doc.article) }
  it 'sorts artists by name within their studio' do
    subject.artists_by_studio.each do |studio, artists|
      expect(artists.map{|a| a.lastname.downcase}).to be_monotonically_increasing
    end
  end

end

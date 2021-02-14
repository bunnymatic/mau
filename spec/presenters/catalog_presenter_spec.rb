require 'rails_helper'

describe CatalogPresenter do
  let!(:open_studios_event) { FactoryBot.create :open_studios_event }
  let!(:artists) do
    FactoryBot.create_list(:artist, 4, :with_studio) + [create(:artist, :active, :in_the_mission)]
  end
  let!(:reception_doc) do
    FactoryBot.create(:cms_document,
                      page: 'main_openstudios',
                      section: 'preview_reception',
                      article: "# pr header\n\n## pr header2\n\ncome out to the *preview* receiption")
  end
  subject(:presenter) { described_class.new }

  before do
    artists[0..1].each do |artist|
      artist.open_studios_events << open_studios_event
    end
    artists.last.open_studios_events << open_studios_event
  end

  its(:csv_filename) { is_expected.to eql "mau_catalog_#{open_studios_event.key}.csv" }

  its(:all_artists) { is_expected.to match_array artists[0..1] + [artists.last] }

  its(:indy_artists) { is_expected.to match_array [artists.last] }

  its(:indy_artists_count) { is_expected.to eql 1 }

  its(:group_studio_artists) do
    is_expected.to match_array artists[0..1]
  end

  its(:preview_reception_data) do
    is_expected.to eql(
      'data-page' => reception_doc.page,
      'data-section' => reception_doc.section,
      'data-cmsid' => reception_doc.id,
    )
  end

  its(:preview_reception_content) do
    is_expected.to eql MarkdownService.markdown(reception_doc.article)
  end

  it 'sorts artists by name within their studio' do
    subject.artists_by_studio.each_value do |artists|
      expect(artists.map { |a| a.lastname.downcase }).to be_monotonically_increasing
    end
  end
end

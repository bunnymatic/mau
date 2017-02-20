require 'rails_helper'

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

  describe '#csv_filename' do
    subject { super().csv_filename }
    it { should eql "mau_catalog_#{open_studios_event.key}.csv" }
  end

  describe '#all_artists' do
    subject { super().all_artists }
    describe '#all' do
      subject { super().all }
      describe '#sort' do
        subject { super().sort }
        it {
          should eql Artist.active.open_studios_participants.all.sort
        }
      end
    end
  end

  describe '#indy_artists' do
    subject { super().indy_artists }
    it { should eql Artist.active.open_studios_participants.reject(&:in_a_group_studio?) }
  end

  describe '#indy_artists_count' do
    subject { super().indy_artists_count }
    it { should eql Artist.active.open_studios_participants.reject(&:in_a_group_studio?).count }
  end

  describe '#group_studio_artists' do
    subject { super().group_studio_artists }
    it { should eql Artist.active.open_studios_participants.select(&:in_a_group_studio?) }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it do
      should eql({
                   "data-page" => reception_doc.page,
                   "data-section" => reception_doc.section,
                   "data-cmsid" => reception_doc.id
                 })
    end
  end

  describe '#preview_reception_content' do
    subject { super().preview_reception_content }
    it { should eql MarkdownService.markdown(reception_doc.article) }
  end
  it 'sorts artists by name within their studio' do
    subject.artists_by_studio.each do |_studio, artists|
      expect(artists.map{|a| a.lastname.downcase}).to be_monotonically_increasing
    end
  end

end

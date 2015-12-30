require 'rails_helper'

describe AdminArtistList, :type => :controller do

  include PresenterSpecHelpers

  let!(:artists) do
    FactoryGirl.create(:artist, :active)
    FactoryGirl.create(:artist, :with_studio)
    FactoryGirl.create(:artist, :with_art)
    FactoryGirl.create(:artist, :pending)
  end

  let(:sort_by) { nil }
  let(:reverse) { nil }
  let(:parsed) { CSV.parse(list.csv,:headers => true) }

  subject(:list) { AdminArtistList.new(sort_by, reverse) }

  describe '#csv_filename' do
    subject { super().csv_filename }
    it { should eql 'mau_artists.csv' }
  end

  describe '#csv_headers' do
    subject { super().csv_headers }
    it { should eql parsed.headers }
  end
  it 'has correct data in the csv' do
    expect(parsed.first['Full Name']).to eql list.artists.first.full_name
  end

  it 'setups up sort links for the view' do
    links = HTML::Document.new(subject.sort_links.join).root
    assert_select links, 'a' do |tags|
      expect(tags.first['href']).to eql admin_artists_path(:sort_by => 'studio_id')
    end
  end

  it 'setups up reverse sort links for the view' do
    links = HTML::Document.new(subject.reverse_sort_links.join).root
    assert_select links, 'a' do |tags|
      expect(tags.first['href']).to eql admin_artists_path(:rsort_by => 'studio_id')
    end
  end

  context 'default' do
    it 'sorts artist by studio id' do
      expect(list.artists.map{|a| a.studio_id.to_i}).to be_monotonically_increasing
    end

    context 'reverse=true' do
      let(:reverse) { true }
      it 'sorts artist by reverse studio id' do
        expect(list.artists.map{|a| a.studio_id.to_i}).to be_monotonically_decreasing
      end

    end
  end

  context 'sort by is an allowed field' do
    let(:sort_by) { :email }
    it 'sorts artist by that field' do
      expect(list.artists.map{|a| a.send(sort_by).to_s}).to be_monotonically_increasing
    end

    context 'reverse=true' do
      let(:reverse) { true }
      it 'sorts artist by reverse of that field' do
        expect(list.artists.map{|a| a.send(sort_by).to_s}).to be_monotonically_decreasing
      end
    end
  end

  context 'sort by is an disallowed field' do
    let(:sort_by) { :whatever }
    it 'sorts artist by that field' do
      expect(list.artists.map{|a| a.send(:studio_id).to_i}).to be_monotonically_increasing
    end

    context 'reverse=true' do
      let(:reverse) { true }
      it 'sorts artist by reverse of that field' do
        expect(list.artists.map{|a| a.send(:studio_id).to_i}).to be_monotonically_decreasing
      end
    end
  end

end

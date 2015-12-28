require 'spec_helper'

describe ArtistsPagination, :type => :controller do

  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) { FactoryGirl.build_list(:user, 9) }

  subject(:paginator) { ArtistsPagination.new(artists, current_page, per_page) }

  describe '#previous_link' do
    subject { super().previous_link }
    it { should eql mock_view_context.artists_path(:p => 0) }
  end

  describe '#next_link' do
    subject { super().next_link }
    it { should eql mock_view_context.artists_path(:p => 2) }
  end

  describe '#first_link' do
    subject { super().first_link }
    it { should eql mock_view_context.artists_path(:p => 0) }
  end

  describe '#last_link' do
    subject { super().last_link }
    it { should eql mock_view_context.artists_path(:p => (artists.length/2)) }
  end

  it '#link_to_next provides a link to the next page' do
    lnk = HTML::Document.new(subject.link_to_next).root
    assert_select lnk, 'a' do |tag|
      expect(tag.first["href"]).to eql subject.next_link
      expect(tag.first["title"]).to eql subject.next_title
    end
  end

  it '#link_to_previous provides a link to the previous page' do
    lnk = HTML::Document.new(subject.link_to_previous).root
    assert_select lnk, 'a' do |tag|
      expect(tag.first['href']).to eql subject.previous_link
      expect(tag.first["title"]).to eql subject.previous_title
    end
  end
end

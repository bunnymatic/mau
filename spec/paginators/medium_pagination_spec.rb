require 'rails_helper'

describe MediumPagination, :type => :controller do

  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create :artist, :with_tagged_art }
  let(:art_pieces) { artist.art_pieces }
  let!(:media) { artist.art_pieces.map(&:medium) }
  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:medium) { media.last }
  let(:page_mode) { }

  subject(:paginator) do
    MediumPagination.new(num_items.times.map{|x| x + 1},
                         medium, current_page, page_mode, per_page )
  end

  describe '#previous_title' do
    subject { super().previous_title }
    it { should eq 'previous' }
  end

  describe '#previous_label' do
    subject { super().previous_label }
    it { should eq '<' }
  end

  describe '#next_title' do
    subject { super().next_title }
    it { should eq 'next' }
  end

  describe '#next_label' do
    subject { super().next_label }
    it { should eq '>' }
  end

  describe '#next_link' do
    subject { super().next_link }
    it { should eq mock_view_context.medium_path(medium, :p => 1) }
  end

  describe '#previous_link' do
    subject { super().previous_link }
    it { should eq mock_view_context.medium_path(medium, :p => 0) }
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

  context 'with different mode' do
    let(:page_mode) { 's' }

    describe '#next_link' do
      subject { super().next_link }
      it { should eq medium_path(medium, :m => 's', :p => 1) }
    end

    describe '#previous_link' do
      subject { super().previous_link }
      it { should eq medium_path(medium,  :m =>'s', :p => 0) }
    end
  end

  context 'with different current page' do
    let(:current_page) { 1 }

    describe '#next_link' do
      subject { super().next_link }
      it { should eq medium_path(medium, :p => 2) }
    end

    describe '#previous_link' do
      subject { super().previous_link }
      it { should eq medium_path(medium, :p => 0) }
    end
  end

end

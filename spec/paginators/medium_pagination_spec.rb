require 'spec_helper'

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

  its(:previous_title) { should eq 'previous' }
  its(:previous_label) { should eq '<' }
  its(:next_title) { should eq 'next' }
  its(:next_label) { should eq '>' }
  its(:next_link) { should eq mock_view_context.medium_path(medium, :p => 1) }
  its(:previous_link) { should eq mock_view_context.medium_path(medium, :p => 0) }

  it '#link_to_next provides a link to the next page' do
    lnk = HTML::Document.new(subject.link_to_next).root
    assert_select lnk, 'a' do |tag|
      tag.first["href"].should eql subject.next_link
      tag.first["title"].should eql subject.next_title
    end
  end

  it '#link_to_previous provides a link to the previous page' do
    lnk = HTML::Document.new(subject.link_to_previous).root
    assert_select lnk, 'a' do |tag|
      tag.first['href'].should eql subject.previous_link
      tag.first["title"].should eql subject.previous_title
    end
  end

  context 'with different mode' do
    let(:page_mode) { 's' }
    its(:next_link) { should eq medium_path(medium, :m => 's', :p => 1) }
    its(:previous_link) { should eq medium_path(medium,  :m =>'s', :p => 0) }
  end

  context 'with different current page' do
    let(:current_page) { 1 }

    its(:next_link) { should eq medium_path(medium, :p => 2) }
    its(:previous_link) { should eq medium_path(medium, :p => 0) }
  end

end

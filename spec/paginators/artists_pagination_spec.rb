require 'spec_helper'

describe ArtistsPagination, :type => :controller do

  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) { FactoryGirl.build_list(:user, 9) }

  subject(:paginator) { ArtistsPagination.new(mock_view_context, artists, current_page, per_page) }

  its(:previous_link) { should eql mock_view_context.artists_path(:p => 0) }
  its(:next_link) { should eql mock_view_context.artists_path(:p => 2) }
  its(:first_link) { should eql mock_view_context.artists_path(:p => 0) }
  its(:last_link) { should eql mock_view_context.artists_path(:p => (artists.length/2)) }

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
end

require 'spec_helper'

describe MediumPagination, :type => :controller do

  include PresenterSpecHelpers

  fixtures :media

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:medium) { Medium.last }
  let(:page_args) { {} }

  subject(:paginator) do
    MediumPagination.new(mock_view_context,
                         num_items.times.map{|x| x + 1},
                         medium, current_page, page_args, per_page )
  end

  its(:previous_title) { should eq 'previous' }
  its(:previous_label) { should eq '&lt;prev' }
  its(:next_title) { should eq 'next' }
  its(:next_label) { should eq 'next&gt;' }
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

  context 'with page arguments' do
    let(:page_args) { {:arg => 's'} }
    its(:next_link) { should eq mock_view_context.medium_path(medium, :arg => 's', :p => 1) }
    its(:previous_link) { should eq mock_view_context.medium_path(medium,  :arg => 's', :p => 0) }
  end

end

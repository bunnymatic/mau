require 'spec_helper'

describe Pagination do

  include PresenterSpecHelpers

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }

  subject(:paginator) { Pagination.new( mock_view_context, num_items.times.map{|x| x + 1}, current_page, per_page ) }

  its(:last_page) { should eq 2 }
  its(:first_page) { should eq 0 }

  it 'raises an error if per_page is not valid' do
    expect{Pagination.new(mock_view_context, [], 1, -1)}.to raise_error PaginationError
  end

  it 'raises an error if you try to access link_to_previous on this base class' do
    expect{paginator.link_to_previous}.to raise_error PaginationError
  end

  it 'raises an error if you try to access link_to_next on this base class' do
    expect{paginator.link_to_next}.to raise_error PaginationError
  end

  context 'on the first page' do
    its(:current_page) { should eq current_page }
    its(:items) { should eq [1,2,3] }
    its(:next_page) { should eq 1 }
    its(:previous_page) { should eq 0 }
    its(:next_link?) { should be_true }
    its(:previous_link?) { should be_false }
    its(:display_current_position) { should eql 'page 1 of 3' }
  end

  context 'on an inner page' do
    let(:current_page) { 1 }

    its(:current_page) { should eq current_page }
    its(:items) { should eq [4,5,6] }
    its(:next_page) { should eq 2 }
    its(:previous_page) { should eq 0 }
    its(:display_current_position) { should eql 'page 2 of 3' }
  end

  context 'on the last page' do
    let(:current_page) { 2 }

    its(:current_page) { should eq current_page }
    its(:items) { should eq [7,8] }
    its(:next_page) { should eq 2 }
    its(:previous_page) { should eq 1 }
    its(:next_link?) { should be_false }
    its(:previous_link?) { should be_true }
    its(:display_current_position) { should eql 'page 3 of 3' }
  end

  context 'when current page is bigger than the number of pages' do
    let(:current_page) { 8 }

    its(:current_page) { should eq 2 }
    its(:items) { should eq [7,8] }
    its(:next_page) { should eq 2 }
    its(:previous_page) { should eq 1 }
    its(:next_link?) { should be_false }
    its(:previous_link?) { should be_true }
  end

  context 'when current page is less than 0' do
    let(:current_page) { -8 }

    its(:current_page) { should eq 0 }
    its(:items) { should eq [1,2,3] }
    its(:next_page) { should eq 1 }
    its(:previous_page) { should eq 0 }
  end

end

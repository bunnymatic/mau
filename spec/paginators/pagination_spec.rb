require 'spec_helper'

describe Pagination do
  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }

  subject(:paginator) { Pagination.new( num_items.times.map{|x| x + 1}, current_page, per_page ) }

  its(:last_page) { should eq 2 }
  its(:first_page) { should eq 0 }

  context 'on the first page' do
    its(:current_page) { should eq current_page }
    its(:items) { should eq [1,2,3] }
    its(:next_page) { should eq 1 }
    its(:previous_page) { should eq 0 }
    its(:next_link?) { should be_true }
    its(:previous_link?) { should be_false }
  end

  context 'on an inner page' do
    let(:current_page) { 1 }

    its(:current_page) { should eq current_page }
    its(:items) { should eq [4,5,6] }
    its(:next_page) { should eq 2 }
    its(:previous_page) { should eq 0 }
  end

  context 'on the last page' do
    let(:current_page) { 2 }

    its(:current_page) { should eq current_page }
    its(:items) { should eq [7,8] }
    its(:next_page) { should eq 2 }
    its(:previous_page) { should eq 1 }
    its(:next_link?) { should be_false }
    its(:previous_link?) { should be_true }
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

  it 'raises an error if per_page is not valid' do
    expect{Pagination.new( [], 1, -1)}.to raise_error PaginationError
  end

end

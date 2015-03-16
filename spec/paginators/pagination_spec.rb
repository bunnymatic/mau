require 'spec_helper'

describe Pagination do

  include PresenterSpecHelpers

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:opts) { nil }
  subject(:paginator) { Pagination.new(num_items.times.map{|x| x + 1}, current_page, per_page, opts ) }

  its(:last_page) { should eq 2 }
  its(:first_page) { should eq 0 }

  it 'raises an error if per_page is not valid' do
    expect{Pagination.new([], 1, -1)}.to raise_error PaginationError
  end

  it 'raises an error if you try to access link_to_previous on this base class' do
    expect{paginator.link_to_previous}.to raise_error PaginationError
  end

  it 'raises an error if you try to access link_to_next on this base class' do
    expect{paginator.link_to_next}.to raise_error PaginationError
  end

  its(:previous_title) { should eq 'previous' }
  its(:previous_label) { should eq '&lt;prev' }
  its(:next_title) { should eq 'next' }
  its(:next_label) { should eq 'next&gt;' }
  its(:pages) { should eq 0..2 }
  context 'when we specify the next and previous labels and titles' do
    let(:opts) {
      {
        previous_title: 'behind',
        previous_label: '<',
        next_title: 'forward',
        next_label: '>'
      }
    }

    its(:previous_title) { should eq 'behind' }
    its(:previous_label) { should eq '<' }
    its(:next_title) { should eq 'forward' }
    its(:next_label) { should eq '>' }
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
    it "reports not the current page for page 2" do
      expect(subject.is_current_page?(2)).to be_false
    end
    it "reports that this is the current page for page 1" do
      expect(subject.is_current_page?(1)).to be_true
    end

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

    its(:current_page) { should eq 8 }
    its(:items) { should eq [] }
    its(:next_page) { should eq 2 }
    its(:previous_page) { should eq 7 }
    its(:next_link?) { should be_false }
    its(:previous_link?) { should be_true }
  end

  context 'when current page is less than 0' do
    let(:current_page) { -8 }

    its(:current_page) { should eq -8 }
    its(:items) { should eq [] }
    its(:next_page) { should eq -7 }
    its(:previous_page) { should eq 0 }
  end

end

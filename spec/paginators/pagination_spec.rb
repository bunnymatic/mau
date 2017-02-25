# frozen_string_literal: true
require 'rails_helper'

describe Pagination do
  include PresenterSpecHelpers

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:opts) { nil }
  subject(:paginator) { Pagination.new(Array.new(num_items) { |x| x + 1 }, current_page, per_page, opts) }

  describe '#last_page' do
    subject { super().last_page }
    it { should eq 2 }
  end

  describe '#first_page' do
    subject { super().first_page }
    it { should eq 0 }
  end

  it 'raises an error if per_page is not valid' do
    expect { Pagination.new([], 1, -1) }.to raise_error PaginationError
  end

  it 'raises an error if you try to access link_to_previous on this base class' do
    expect { paginator.link_to_previous }.to raise_error PaginationError
  end

  it 'raises an error if you try to access link_to_next on this base class' do
    expect { paginator.link_to_next }.to raise_error PaginationError
  end

  describe '#previous_title' do
    subject { super().previous_title }
    it { should eq 'previous' }
  end

  describe '#previous_label' do
    subject { super().previous_label }
    it { should eq '&lt;prev' }
  end

  describe '#next_title' do
    subject { super().next_title }
    it { should eq 'next' }
  end

  describe '#next_label' do
    subject { super().next_label }
    it { should eq 'next&gt;' }
  end

  describe '#pages' do
    subject { super().pages }
    it { should eq 0..2 }
  end
  context 'when we specify the next and previous labels and titles' do
    let(:opts) do
      {
        previous_title: 'behind',
        previous_label: '<',
        next_title: 'forward',
        next_label: '>'
      }
    end

    describe '#previous_title' do
      subject { super().previous_title }
      it { should eq 'behind' }
    end

    describe '#previous_label' do
      subject { super().previous_label }
      it { should eq '<' }
    end

    describe '#next_title' do
      subject { super().next_title }
      it { should eq 'forward' }
    end

    describe '#next_label' do
      subject { super().next_label }
      it { should eq '>' }
    end
  end
  context 'on the first page' do
    describe '#current_page' do
      subject { super().current_page }
      it { should eq current_page }
    end

    describe '#items' do
      subject { super().items }
      it { should eq [1, 2, 3] }
    end

    describe '#next_page' do
      subject { super().next_page }
      it { should eq 1 }
    end

    describe '#previous_page' do
      subject { super().previous_page }
      it { should eq 0 }
    end

    describe '#next_link?' do
      subject { super().next_link? }
      it { should eq(true) }
    end

    describe '#previous_link?' do
      subject { super().previous_link? }
      it { should eq(false) }
    end

    describe '#display_current_position' do
      subject { super().display_current_position }
      it { should eql 'page 1 of 3' }
    end
  end

  context 'on an inner page' do
    let(:current_page) { 1 }

    describe '#current_page' do
      subject { super().current_page }
      it { should eq current_page }
    end

    describe '#items' do
      subject { super().items }
      it { should eq [4, 5, 6] }
    end

    describe '#next_page' do
      subject { super().next_page }
      it { should eq 2 }
    end

    describe '#previous_page' do
      subject { super().previous_page }
      it { should eq 0 }
    end

    describe '#display_current_position' do
      subject { super().display_current_position }
      it { should eql 'page 2 of 3' }
    end
    it 'reports not the current page for page 2' do
      expect(subject.is_current_page?(2)).to eq(false)
    end
    it 'reports that this is the current page for page 1' do
      expect(subject.is_current_page?(1)).to eq(true)
    end
  end

  context 'on the last page' do
    let(:current_page) { 2 }

    describe '#current_page' do
      subject { super().current_page }
      it { should eq current_page }
    end

    describe '#items' do
      subject { super().items }
      it { should eq [7, 8] }
    end

    describe '#next_page' do
      subject { super().next_page }
      it { should eq 2 }
    end

    describe '#previous_page' do
      subject { super().previous_page }
      it { should eq 1 }
    end

    describe '#next_link?' do
      subject { super().next_link? }
      it { should eq(false) }
    end

    describe '#previous_link?' do
      subject { super().previous_link? }
      it { should eq(true) }
    end

    describe '#display_current_position' do
      subject { super().display_current_position }
      it { should eql 'page 3 of 3' }
    end
  end

  context 'when current page is bigger than the number of pages' do
    let(:current_page) { 8 }

    describe '#current_page' do
      subject { super().current_page }
      it { should eq 8 }
    end

    describe '#items' do
      subject { super().items }
      it { should eq [] }
    end

    describe '#next_page' do
      subject { super().next_page }
      it { should eq 2 }
    end

    describe '#previous_page' do
      subject { super().previous_page }
      it { should eq 7 }
    end

    describe '#next_link?' do
      subject { super().next_link? }
      it { should be_falsey }
    end

    describe '#previous_link?' do
      subject { super().previous_link? }
      it { should eq(true) }
    end
  end

  context 'when current page is less than 0' do
    let(:current_page) { -8 }

    its(:current_page) { is_expected.to eql(-8) }
    its(:next_page) { is_expected.to eql(-7) }
    its(:previous_page) { is_expected.to eql(0) }
    its(:items) { is_expected.to eql([]) }
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe ArtPieceTagPagination do
  include PresenterSpecHelpers
  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:tag) { instance_double(ArtPieceTag) }
  let(:mode) { nil }

  subject(:paginator) do
    ArtPieceTagPagination.new(Array.new(num_items) { |x| x + 1 },
                              tag, current_page, mode, per_page)
  end

  context 'with minimal arguments' do
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
      it { should eq art_piece_tag_path(tag, p: 1) }
    end

    describe '#previous_link' do
      subject { super().previous_link }
      it { should eq art_piece_tag_path(tag, p: 0) }
    end
  end

  context 'with different mode' do
    let(:mode) { 's' }

    describe '#next_link' do
      subject { super().next_link }
      it { should eq art_piece_tag_path(tag, p: 1, m: 's') }
    end

    describe '#previous_link' do
      subject { super().previous_link }
      it { should eq art_piece_tag_path(tag, p: 0, m: 's') }
    end
  end

  context 'with different current page' do
    let(:current_page) { 1 }

    describe '#next_link' do
      subject { super().next_link }
      it { should eq art_piece_tag_path(tag, p: 2) }
    end

    describe '#previous_link' do
      subject { super().previous_link }
      it { should eq art_piece_tag_path(tag, p: 0) }
    end
  end
end

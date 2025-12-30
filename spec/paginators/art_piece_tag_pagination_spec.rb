require 'rails_helper'

describe ArtPieceTagPagination do
  include PresenterSpecHelpers

  let(:num_items) { 8 }
  let(:per_page) { 3 }
  let(:current_page) { 0 }
  let(:tag) { instance_double(ArtPieceTag) }

  subject(:paginator) do
    ArtPieceTagPagination.new(Array.new(num_items) { |x| x + 1 },
                              tag,
                              current_page,
                              per_page)
  end

  context 'with minimal arguments' do
    describe '#previous_title' do
      it { expect(paginator.previous_title).to eq 'previous' }
    end

    describe '#previous_label' do
      it { expect(paginator.previous_label).to eq '<' }
    end

    describe '#next_title' do
      it { expect(paginator.next_title).to eq 'next' }
    end

    describe '#next_label' do
      it { expect(paginator.next_label).to eq '>' }
    end

    describe '#next_link' do
      it { expect(paginator.next_link).to eq art_piece_tag_path(tag, p: 1) }
    end

    describe '#previous_link' do
      it { expect(paginator.previous_link).to eq art_piece_tag_path(tag, p: 0) }
    end
  end

  context 'with different current page' do
    let(:current_page) { 1 }

    describe '#next_link' do
      it { expect(paginator.next_link).to eq art_piece_tag_path(tag, p: 2) }
    end

    describe '#previous_link' do
      it { expect(paginator.previous_link).to eq art_piece_tag_path(tag, p: 0) }
    end
  end
end

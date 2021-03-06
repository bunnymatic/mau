require 'rails_helper'

describe ArtPieceServiceTagsHandler do
  let(:dummy_class) do
    Class.new do
      include ArtPieceServiceTagsHandler
      def initialize(parms)
        @params = parms
      end
    end
  end
  let!(:existing_tags) { create_list :art_piece_tag, 2 }
  let(:existing_tag) { existing_tags.first }
  subject(:dummy) { dummy_class.new(ActionController::Parameters.new(params)) }

  describe '#prepare_tags_params' do
    context 'with tags' do
      let(:params) { { tag_ids: ['', existing_tag.name, existing_tag.id.to_s, 'that', 'the other'] } }
      it 'returns tags' do
        subject.prepare_tags_params
        prepared_params = subject.instance_variable_get(:@params)
        tags = prepared_params[:tags]
        expect(tags).to have(3).items
        expect(tags).to be_all(ArtPieceTag)
      end

      it 'creates new tags as needed' do
        subject.prepare_tags_params
        prepared_params = subject.instance_variable_get(:@params)
        tags = prepared_params[:tags]
        new_tags = ArtPieceTag.where(name: ['that', 'the other'])
        expect(new_tags).to have(2).items
        expect(tags).to include(*new_tags)
      end

      it 'does not create duplicates' do
        subject.prepare_tags_params
        prepared_params = subject.instance_variable_get(:@params)
        tags = prepared_params[:tags]
        new_tags = ArtPieceTag.where(name: [existing_tag.name, existing_tag.id.to_s, 'That', 'that', 'the other'])
        expect(new_tags).to have(3).items
        expect(tags).to include(*new_tags)
      end
    end
  end
end

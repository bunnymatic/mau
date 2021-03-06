require 'rails_helper'

describe StudiosController do
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:manager) { FactoryBot.create(:artist, :with_studio, :manager) }
  let(:indy_artist) { FactoryBot.create(:artist, :active) }
  let(:artist) { FactoryBot.create(:artist, :with_studio, :active) }
  let(:manager_studio) { manager.studio }
  let(:studio) { manager.studio }

  let!(:studios) { [manager, indy_artist, artist].map(&:studio) }

  describe '#show' do
    it 'gets independent studio with the slug' do
      get :show, params: { id: 'independent-studios' }
      expect(assigns(:studio).name).to eql 'Independent Studios'
    end

    describe 'unknown studio' do
      before do
        get :show, params: { id: 'blurp' }
      end
      it { expect(response).to redirect_to studios_path }
      it 'sets the flash' do
        expect(flash[:error]).to be_present
      end
    end

    describe 'individual studio' do
      describe 'html' do
        before do
          allow_any_instance_of(Studio).to receive(:phone).and_return('1234569999')
          allow_any_instance_of(Studio).to receive(:cross_street).and_return('fillmore')
          get :show, params: { id: studio.slug, format: 'html' }
        end
        it { expect(response).to be_successful }
      end
    end
  end
end

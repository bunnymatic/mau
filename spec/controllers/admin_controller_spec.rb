require 'rails_helper'

describe AdminController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:pending_artist) { FactoryBot.create(:artist, :with_studio, state: 'pending', nomdeplume: "With A'Postr") }
  let(:artist) { FactoryBot.create(:artist, :with_studio) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:editor) { FactoryBot.create(:artist, :editor) }
  let(:manager) { FactoryBot.create(:artist, :manager, :with_studio) }
  let(:artist2) { manager }

  context 'authorization' do
    %i[index os_status].each do |endpoint|
      describe 'not logged in' do
        describe endpoint.to_s do
          before do
            get endpoint
          end
          it_behaves_like 'not authorized'
        end
      end
      describe 'logged in as plain user' do
        describe endpoint.to_s do
          before do
            login_as fan
            get endpoint
          end
          it_behaves_like 'not authorized'
        end
      end
      it "#{endpoint} responds success if logged in as admin" do
        login_as admin
        get endpoint
        expect(response).to be_successful
      end
    end
  end

  describe '#os_status' do
    before do
      open_studios = create(:open_studios_event)
      Artist.active.each do |artist|
        artist.open_studios_events << open_studios
      end
      login_as admin
      get :os_status
    end
    it 'returns success' do
      expect(response).to be_successful
    end
    it 'sets a list of artists in alpha order by last name' do
      expect(assigns(:artists)).to have(Artist.active.count).items
      expect(assigns(:artists).map { |a| a.lastname.downcase }).to be_monotonically_increasing
      expect(assigns(:totals).count).to eql 1
    end
  end
end

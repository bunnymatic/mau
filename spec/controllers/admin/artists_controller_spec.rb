# frozen_string_literal: true

require 'rails_helper'

describe Admin::ArtistsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:pending) { FactoryBot.create(:artist, :pending, activation_code: 'ACTIVATEME') }
  let(:password_reset) { FactoryBot.create(:artist, :active, reset_code: 'RESET') }
  let!(:artist) { FactoryBot.create(:artist, :with_studio) }
  let(:artist2) { FactoryBot.create(:artist, :active) }
  let(:manager) { FactoryBot.create(:artist, :active, :with_studio, :manager) }
  let(:current_os) { FactoryBot.create(:open_studios_event, :future) }

  describe '#index' do
    context 'while not logged in' do
      before do
        get :index
      end
      it 'redirects to error' do
        expect(response).to redirect_to '/error'
      end
    end
    context 'while logged in as user' do
      before do
        login_as(artist2)
        get :index
      end
      it 'should report error' do
        expect(response).to redirect_to '/error'
      end
    end
    context 'logged in as admin' do
      before do
        login_as admin
      end
      context 'format=html' do
        context 'with no params' do
          before do
            allow_any_instance_of(ArtistInfo).to receive(:os_participation).and_return(current_os.key => true)
            allow_any_instance_of(Artist).to receive(:os_participation).and_return({ current_os.key => true }, address: { yes: 'we do' })
            pending
            password_reset
            get :index
          end
          it { expect(response).to be_success }
        end
      end
      context 'format=csv' do
        let(:parse_args) { ViewPresenter::DEFAULT_CSV_OPTS.merge(headers: true) }
        let(:parsed) { CSV.parse(response.body, parse_args) }

        before do
          get :index, params: { format: :csv }
        end

        it { expect(response).to be_success }
        it { expect(response).to be_csv_type }

        it 'includes the right headers' do
          expected_headers = ['Login', 'First Name', 'Last Name', 'Full Name', 'Group Site Name',
                              'Studio Address', 'Studio Number', 'Email Address']
          expect(parsed.headers).to eq(expected_headers)
        end
        it 'includes the right data' do
          expect(parsed.size).to eq(Artist.all.count)
          row = parsed.detect { |r| r['Full Name'] == artist.full_name }
          expect(row).to be_present
          expect(row['Login']).to eql artist.login
          expect(row['Group Site Name']).to eql artist.studio.name
        end
      end
    end
  end
end

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
      it_behaves_like 'not authorized'
    end
    context 'while logged in as user' do
      before do
        login_as(artist2)
        get :index
      end
      it_behaves_like 'not authorized'
    end
    context 'logged in as admin' do
      before do
        login_as admin
      end
      context 'format=html' do
        context 'with no params' do
          before do
            pending
            password_reset
            get :index
          end
          it { expect(response).to be_successful }
        end
      end
      context 'format=csv' do
        let(:parse_args) { ViewPresenter::DEFAULT_CSV_OPTS.merge(headers: true) }
        let(:parsed) { CSV.parse(response.body, parse_args) }

        before do
          get :index, params: { format: :csv }
        end

        it { expect(response).to be_successful }
        it { expect(response).to be_csv_type }

        it 'includes the right headers' do
          expected_headers = [
            'Login',
            'First Name',
            'Last Name',
            'Full Name',
            'Group Site Name',
            'Studio Address',
            'Studio Number',
            'Email Address',
            'No Current Open Studios',
            'Show Phone',
            'Show Email',
            'Shop Url',
            'Youtube Url',
            'Video Conference Url',
          ]
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

  describe '#bulk_update' do
    let(:artists) { create_list(:artist, 2, :active, :with_studio) }
    let(:params) do
      artists.each_with_object({}).with_index do |(artist, memo), idx|
        memo[artist.id] = !!idx.even?
      end
    end

    before do
      login_as admin
    end

    context 'when there are artists to change' do
      before do
        create(:open_studios_event, :future)
        post :bulk_update, params: { os: params }
      end

      it 'updates requested artists' do
        updated = artists.map(&:reload)
        expect(updated[0]).to be_doing_open_studios
        expect(updated[1]).not_to be_doing_open_studios
      end

      it 'redirects to the admin artist index' do
        expect(response).to redirect_to admin_artists_path
      end

      it 'flashes what happened' do
        expect(flash[:notice]).to include 'Updated setting for'
      end
    end

    context 'when there is no current open studios' do
      before do
        post :bulk_update, params: { os: params }
      end
      it 'flashes an error' do
        expect(flash[:alert]).to include 'must have an Open Studios'
      end
      it 'redirects to the admin artist index' do
        expect(response).to redirect_to admin_artists_path
      end
    end
  end
end

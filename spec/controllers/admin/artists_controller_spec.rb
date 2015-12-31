require 'rails_helper'

describe Admin::ArtistsController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:pending) { FactoryGirl.create(:artist, :pending, activation_code: 'ACTIVATEME') }
  let(:password_reset) { FactoryGirl.create(:artist, :active, reset_code: "RESET") }
  let!(:artist) { FactoryGirl.create(:artist, :with_studio) }
  let(:artist2) { FactoryGirl.create(:artist, :active) }
  let(:manager) { FactoryGirl.create(:artist, :active, :with_studio, :manager) }
  let(:current_os) { FactoryGirl.create(:open_studios_event, :future) }

  describe "#index" do
    context "while not logged in" do
      before do
        get :index
      end
      it "redirects to error" do
        expect(response).to redirect_to '/error'
      end
    end
    context "while logged in as user" do
      before do
        login_as(artist2)
        get :index
      end
      it "should report error" do
        expect(response).to redirect_to '/error'
      end
    end
    context "logged in as admin" do
      before do
        login_as admin
      end
      context 'format=html' do
        context 'with no params' do
          render_views
          before do
            allow_any_instance_of(ArtistInfo).to receive(:os_participation).and_return({ current_os.key => true})
            allow_any_instance_of(Artist).to receive(:os_participation).and_return({ current_os.key => true}, address: { yes: 'we do' })
            pending
            password_reset
            get :index
          end
          it { expect(response).to be_success }
          it 'renders a csv export link' do
            assert_select('a.export-csv', /Export/)
          end
          it 'renders activation link for inactive artists' do
            activation_url = activate_url(activation_code: pending.activation_code)
            assert_select("tr.pending a[href=#{artist_path(pending)}]")
            assert_select('.activation-link', count: Artist.all.select{|a| !a.active? && a.activation_code.present?}.count)
            assert_select('.activation-link .tooltip-content', text: activation_url )
          end
          it 'renders forgot link if there is a reset code' do
            assert_select('.forgot-password-link',
                          count: Artist.all.select{|s| s.reset_code.present?}.count)
            assert_select('.forgot-password-link .tooltip-content',
                          match: reset_url(reset_code: password_reset.reset_code))
          end
        end
      end
      context 'format=csv' do
        let(:parse_args) { ApplicationController::DEFAULT_CSV_OPTS.merge({headers:true}) }
        let(:parsed) { CSV.parse(response.body, parse_args) }

        before do
          get :index, 'format' => 'csv'
        end

        it { expect(response).to be_success }
        it { expect(response).to be_csv_type }

        it 'includes the right headers' do
          expected_headers = ["Login", "First Name","Last Name","Full Name","Group Site Name",
                              "Studio Address","Studio Number","Email Address"]
          expect(parsed.headers).to eq(expected_headers)
        end
        it 'includes the right data' do
          expect(parsed.size).to eq(Artist.all.count)
          row = parsed.detect{|row| row['Full Name'] == artist.full_name}
          expect(row).to be_present
          expect(row['Login']).to eql artist.login
          expect(row["Group Site Name"]).to eql artist.studio.name
        end
      end
    end
  end

  describe '#notify_featured' do
    describe 'unauthorized' do
      it 'not logged in redirects to error' do
        post :notify_featured, id: artist.id
        expect(response).to redirect_to '/error'
      end
      it 'logged in as normal redirects to error' do
        login_as manager
        post :notify_featured, id: artist.id
        expect(response).to redirect_to '/error'
      end
    end
    describe 'authorized' do
      before do
        login_as admin
      end
      it 'returns success' do
        post :notify_featured, id: artist.id
        expect(response).to be_success
      end
      it 'calls the notify_featured mailer' do
        expect(ArtistMailer).to receive(:notify_featured).exactly(:once).and_return(double(:deliver => true))
        post :notify_featured, id: artist.id
      end
    end
  end


end

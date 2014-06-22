require 'spec_helper'

describe Admin::ArtistsController do

  fixtures :users, :roles_users,  :roles, :studios
  let(:artist1) { users(:artist1) }
  let(:artist2) { users(:joeblogs) }

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
        login_as :admin
      end
      context 'format=html' do
        context 'with no params' do
          render_views
          before do
            ArtistInfo.any_instance.stub(:os_participation => {'201204' => true})
            Artist.any_instance.stub(:os_participation => {'201204' => true})

            get :index
          end
          it_should_behave_like 'logged in as admin'
          it "returns success" do
            expect(response).to be_success
          end
          it 'renders a csv export link' do
            assert_select('a.export-csv button', /export/)
          end
          it 'renders an update os status button' do
            assert_select('button.update-artists', /update os status/)
          end
          it 'renders .pending rows for all pending artists' do
            assert_select('tr.pending', :count => Artist.pending.count)
          end
          it 'renders .suspended rows for all suspended artists' do
            assert_select('tr.suspended', :count => Artist.all.select{|s| s.state == 'suspended'}.count)
          end
          it 'renders .deleted rows for all deleted artists' do
            assert_select('tr.deleted', :count => Artist.all.select{|s| s.state == 'deleted'}.count)
          end
          it 'renders created_at date for all pending artists' do
            Artist.all.select{|s| s.state == 'pending'}.each do |a|
              expected_match = a.created_at.strftime("%m/%d/%y")
              assert_select('tr.pending td', /#{expected_match}/)
            end
          end
          it 'renders .participating rows for all pending artists' do
            assert_select('tr.participating', :count => Artist.all.select{|a| a.os_participation['201210']}.count)
          end
          it 'renders activation link for inactive artists' do
            activation_url = activate_url(:activation_code => users(:pending_artist).activation_code)
            assert_select('.activation_link', :count => Artist.all.select{|s| s.state == 'pending'}.count)
            assert_select('.activation_link', :match => activation_url )
          end
          it 'renders forgot link if there is a reset code' do
            assert_select('.forgot_password_link',
                          :count => Artist.all.select{|s| s.reset_code.present?}.count)
            assert_select('.forgot_password_link',
                          :match => reset_url(:reset_code => users(:reset_password).reset_code))
          end
        end
      end
      context 'format=csv' do
        let(:parse_args) { ApplicationController::DEFAULT_CSV_OPTS.merge({:headers =>true}) }
        let(:parsed) { CSV.parse(response.body, parse_args) }
        let(:artist) { users(:artist1) }

        before do
          get :index, 'format' => 'csv'
        end

        it { expect(response).to be_success }
        it { expect(response).to be_csv_type }

        it 'includes the right headers' do
          expected_headers = ["Login", "First Name","Last Name","Full Name","Group Site Name",
                              "Studio Address","Studio Number","Email Address"]
          parsed.headers.should == expected_headers
        end
        it 'includes the right data' do
          expect(parsed).to have(Artist.all.count).rows
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
        post :notify_featured, :id => artist1.id
        expect(response).to redirect_to '/error'
      end
      it 'logged in as normal redirects to error' do
        login_as :manager
        post :notify_featured, :id => artist1.id
        expect(response).to redirect_to '/error'
      end
    end
    describe 'authorized' do
      before do
        login_as :admin
      end
      it 'returns success' do
        post :notify_featured, :id => artist1.id
        expect(response).to be_success
      end
      it 'calls the notify_featured mailer' do
        ArtistMailer.should_receive(:notify_featured).exactly(:once).and_return(double(:deliver! => true))
        post :notify_featured, :id => artist1.id
      end
    end
  end


end

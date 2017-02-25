# frozen_string_literal: true
require 'rails_helper'

describe Admin::MemberEmailsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:pending_artist) { FactoryGirl.create(:artist, :with_studio, state: 'pending', nomdeplume: "With A'Postr") }

  include OpenStudiosEventShim

  describe '#show' do
    before do
      login_as admin
    end

    describe 'html' do
      context 'with no params' do
        before do
          get :show
        end
        it 'returns success' do
          expect(response).to be_success
        end
        it 'assigns the title' do
          expect(assigns(:email_list).title).to eql "Activated"
        end
        it 'assigns list of artists emails' do
          expect(assigns(:email_list).emails.length).to eql Artist.active.count
        end
      end

      describe 'multiple os keys' do
        before do
          get :show, params: { '201004' => 'on', '201010' => 'on' }
        end
        it 'sets up the correct list name' do
          expect(assigns(:email_list).list_names).to eql(%w|201004 201010|)
        end
      end

      [:all, :active, :pending, :no_images, :no_profile ].each do |list_name|
        describe "list name = #{list_name}" do
          before do
            get :show, params: { listname: list_name }
          end
          it 'sets the right list name' do
            expect(assigns(:email_list).list_names).to eql [list_name.to_s]
          end
        end
      end
    end

    describe 'csv' do
      let(:parse_args) { ViewPresenter::DEFAULT_CSV_OPTS.merge(headers:true) }
      let(:parsed) { CSV.parse(response.body, parse_args) }
      before do
        pending_artist
        get :show, params: { format: :csv, listname: 'pending' }
      end
      it { expect(response).to be_success }
      it { expect(response).to be_csv_type }
      it 'includes the right headers' do
        past_os_event_keys = %w|201004 201010 201104 201110 201204 201210 201304 201310 201404|
        expected_headers = ["First Name","Last Name","Full Name","Email Address","Group Site Name"]
        expected_headers += past_os_event_keys
        expect(parsed.headers).to eq(expected_headers)
      end
      it 'includes the right data' do
        expect(parsed.length).to eql 1
        expect(parsed.first["Full Name"]).to eql pending_artist.full_name
        expect(parsed.first["Group Site Name"]).to eql pending_artist.studio.name
      end
    end
  end
end

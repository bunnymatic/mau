# frozen_string_literal: true
require 'rails_helper'

shared_examples_for 'successful notes mailer response' do
  it { expect(response).to be_success }
  it { expect(JSON.parse(response.body)['success']).to eql true }
end

shared_examples_for 'has some invalid params' do
  it { expect(response).to be_4xx }
  it { expect(JSON.parse(response.body)['success']).to eql false }
  it { expect(JSON.parse(response.body)['error_messages']).to be_present }
end

describe MainController do
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:editor) { FactoryBot.create(:artist, :active, :editor) }
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:artist) { FactoryBot.create(:artist, :active, :with_art) }
  let(:prolific_artist) { FactoryBot.create(:artist, :active, :with_art, number_of_art_pieces: 15) }

  before do
    # seems like we have leaky database records
    fix_leaky_fixtures
    artist
    prolific_artist
    FactoryBot.create(:open_studios_event, :future)
  end

  describe '#index' do
    context 'not logged in' do
      before do
        get :index
      end
      it { expect(response).to be_success }
    end
  end

  describe '#news' do
    before do
      get :resources
    end
    it { expect(response).to be_success }
  end

  describe '#about' do
    context 'while not logged in' do
      before do
        FactoryBot.create(:cms_document, page: :main, section: :about)
        get :about
      end
      it { expect(response).to be_success }
      it 'fetches markdown content' do
        expect(assigns(:content)).to have_key :content
        expect(assigns(:content)).to have_key :cmsid
      end
    end
  end

  describe '#privacy' do
    before do
      get :privacy
    end
    it { expect(response).to be_success }
  end

  describe '#faq' do
    before do
      get :faq
    end
    it { expect(response).to be_success }
  end

  describe '#main/venues' do
    context 'while not logged in' do
      before do
        get :venues
      end
      it { expect(response).to be_success }
    end
    context 'logged in as admin' do
      let(:venue_doc) do
        FactoryBot.create(:cms_document,
                          page: :venues,
                          section: :all,
                          article: "# these \n\n## are \n\n### venues \n\n* one\n* two\n* three")
      end
      before do
        venue_doc
        login_as(admin)
        get :venues
      end
    end
  end

  describe 'notes mailer' do
    describe 'xhr post' do
      before do
        post :notes_mailer, xhr: true, params: { feedback_mail: { stuff: 'whatever' } }
        @resp = JSON.parse(response.body)
      end
      it { expect(response).to be_4xx }
      it "response reports 'invalid note type'" do
        expect(@resp['error_messages']).to include "Email can't be blank"
        expect(@resp['error_messages']).to include "Email confirm can't be blank"
        expect(@resp['error_messages']).to include 'Note type  is not a valid note type'
      end
    end

    describe 'submission given invalid note_type' do
      before do
        post :notes_mailer, xhr: true, params: {
          feedback_mail: {
            note_type: 'bogus',
            email: 'a@b.com'
          }
        }
        @resp = JSON.parse(response.body)
      end
      it { expect(response).to be_4xx }
    end

    describe 'submission given note_type email_list and email only' do
      before do
        post :notes_mailer, xhr: true, params: {
          feedback_mail: {
            note_type: 'email_list',
            email: 'a@b.com'
          }
        }
        @resp = JSON.parse(response.body)
      end
      it_should_behave_like 'has some invalid params'
    end

    describe 'submission given note_type inquiry, both emails but no inquiry' do
      before do
        post :notes_mailer, xhr: true, params: {
          feedback_mail: {
            note_type: 'inquiry',
            email: 'a@b.com',
            email_confirm: 'a@b.com'
          }
        }
        @resp = JSON.parse(response.body)
      end
      it_should_behave_like 'has some invalid params'
    end

    describe 'submission with valid params' do
      context 'inquiry' do
        before do
          post :notes_mailer, xhr: true, params: {
            feedback_mail: {
              note_type: 'inquiry',
              inquiry: 'cool note',
              email: 'a@b.com',
              email_confirm: 'a@b.com'
            }
          }
          @resp = JSON.parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end

      context 'help' do
        before do
          post :notes_mailer, xhr: true, params: {
            feedback_mail: {
              note_type: 'help',
              inquiry: 'cool note',
              email: 'a@b.com',
              email_confirm: 'a@b.com'
            }
          }
          @resp = JSON.parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end
    end
  end

  describe 'status' do
    it 'hits the database' do
      expect(Medium).to receive :first
      get :status_page
    end
    it 'returns success' do
      get :status_page
      expect(response).to be_success
    end
  end

  describe 'version' do
    it 'returns the app version' do
      get :version
      expect(response.body).to eql Mau::Version.new.to_s
    end
  end

  describe 'sampler' do
    before do
      get :sampler
    end

    it 'renders the thumbs partial' do
      expect(response).to render_template 'main/_sampler_thumb'
    end
  end
end

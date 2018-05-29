# frozen_string_literal: true

require 'rails_helper'

describe Api::NotesController do
  # frozen_string_literal: true
  shared_examples_for 'has some invalid params' do
    it { expect(response).to be_4xx }
    it { expect(JSON.parse(response.body)['success']).to eql false }
    it { expect(JSON.parse(response.body)['error_messages']).to be_present }
  end

  describe '#create' do
    before do
      request.env['HTTP_REFERER'] = 'http://test.host/'
    end
    describe 'with no emali or note type' do
      before do
        post :create, xhr: true, params: { feedback_mail: { stuff: 'whatever' } }
        @resp = JSON.parse(response.body)

        it { expect(response).to be_4xx }
        it "response reports 'invalid note type'" do
          expect(@resp['error_messages']).to include "Email can't be blank"
          expect(@resp['error_messages']).to include "Email confirm can't be blank"
          expect(@resp['error_messages']).to include 'Note type  is not a valid note type'
        end
      end
    end
    describe 'submission given invalid note_type' do
      before do
        post :create, xhr: true, params: {
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
        post :create, xhr: true, params: {
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
        post :create, xhr: true, params: {
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
          post :create, xhr: true, params: {
            feedback_mail: {
              note_type: 'inquiry',
              inquiry: 'cool note',
              email: 'a@b.com',
              email_confirm: 'a@b.com'
            }
          }
          @resp = JSON.parse(response.body)
        end
        it { expect(response).to be_success }
        it { expect(JSON.parse(response.body)['success']).to eql true }
      end

      context 'help' do
        before do
          post :create, xhr: true, params: {
            feedback_mail: {
              note_type: 'help',
              inquiry: 'cool note',
              email: 'a@b.com',
              email_confirm: 'a@b.com'
            }
          }
          @resp = JSON.parse(response.body)
        end
        it { expect(response).to be_success }
        it { expect(JSON.parse(response.body)['success']).to eql true }
      end
    end
  end
end

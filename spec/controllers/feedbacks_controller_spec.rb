# frozen_string_literal: true

require 'rails_helper'

describe FeedbacksController do
  describe '#new' do
    before do
      get :new
    end
    it { expect(response).to be_successful }
    it 'sets a new feedback' do
      expect(assigns(:feedback)).to be_a_kind_of Feedback
      expect(assigns(:feedback)).to be_new_record
    end
    it 'sets the title' do
      expect(assigns(:title)).to eql 'Feedback'
    end
    it 'sets the section to general' do
      expect(assigns(:section)).to eql 'general'
    end
  end

  describe '#create' do
    context 'with no info' do
      before do
        get :create, params: { feedback: { whatever: 'blah' } }
      end
      it { expect(assigns(@error_message)).to be_present }
      it { expect(response).to render_template :new }
      it { expect(response.status).to eql 422 }
    end
    context 'with good data' do
      before do
        expect(FeedbackMailer).to receive(:feedback).and_return(double(deliver_later: true))
        expect do
          attrs = FactoryBot.attributes_for(:feedback)
          get :create, params: {
            feedback: attrs,
          }
        end.to change(Feedback, :count).by(1)
      end
      it { expect(response).to be_successful }
      it { expect(response).to render_template :thankyou }
    end
  end
end

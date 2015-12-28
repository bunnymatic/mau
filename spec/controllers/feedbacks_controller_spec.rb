require 'spec_helper'

describe FeedbacksController do
  describe '#new' do
    before do
      get :new
    end
    it { expect(response).to be_success }
    it "sets a new feedback" do
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
        get :create, :feedback => { :whatever => 'blah' }
      end
      it { expect(assigns(@error_message)).to be_present }
      it { expect(response).to render_template :new }
      it { expect(response.status).to eql 422 }
    end
    context 'with good data' do
      before do
        expect(FeedbackMailer).to receive(:feedback).and_return(double(:deliver! => true))
        expect{
          get :create, {:feedback => {
              :email => 'joe@wherever.com',
              :comment => 'this is the comment',
              :subject => 'this is the subject'}
          }
        }.to change(Feedback, :count).by(1)
      end
      it {expect(response).to be_success}
      it {expect(response).to render_template :thankyou}
    end

  end
end

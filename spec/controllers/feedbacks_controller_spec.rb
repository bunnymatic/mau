require 'spec_helper'

describe FeedbacksController do
  describe '#new' do
    before do
      get :new
    end
    it { response.should be_success }
    it "sets a new feedback" do
      assigns(:feedback).should be_a_kind_of Feedback
      assigns(:feedback).should be_new_record
    end
    it 'sets the title' do
      assigns(:title).should eql 'Feedback'
    end
    it 'sets the section to general' do
      assigns(:section).should eql 'general'
    end
  end

  describe '#create' do
    context 'with no info' do
      before do
        get :create, {:feedback => {}}
      end
      it { assigns(@error_message).should be_present }
      it { response.should render_template :new }
      it { response.status.should eql 422 }
    end
    context 'with good data' do
      before do
        FeedbackMailer.should_receive(:feedback).and_return(double(:deliver! => true))
        expect{
          get :create, {:feedback => {:email => 'joe@wherever.com', :comment => 'this is the comment', :subject => 'this is the subject'}}
        }.to change(Feedback, :count).by(1)
      end
      it {response.should be_success}
      it {response.should render_template :thankyou}
    end

  end
end

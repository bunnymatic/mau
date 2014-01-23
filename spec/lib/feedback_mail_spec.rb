require 'spec_helper'

describe FeedbackMail do

  let(:feedback_params) { FactoryGirl.attributes_for(:feedback_mail) }
  subject(:feedback_mail) { FactoryGirl.build(:feedback_mail) }

  it{ should validate_presence_of :email }
  it{ should validate_presence_of :email_confirm }
  it{ should validate_presence_of :note_type }
  it{ should ensure_inclusion_of(:note_type).in_array(FeedbackMail::VALID_NOTE_TYPES) }

  context 'if emails don\'t match (and are required' do
    subject(:feedback_mail) {
      FactoryGirl.build(:feedback_mail,
                        :email => 'jon@here.com',
                        :email_confirm => 'joe@here.com')
    }
    it{ should_not be_valid }
    it 'includes the errors on base' do
      subject.valid?
      subject.errors[:base].join.should include 'reconfirm your email'
    end
  end

  context 'if it\'s a feed submission' do
    let(:comment) { subject.comment }
    subject(:feedback_mail) { FactoryGirl.build(:feedback_mail, :note_type => 'feed_submission') }
    it{ should_not validate_presence_of :email }
    it{ should_not validate_presence_of :email_confirm }
    it{ should validate_presence_of :feedlink }

    it 'includes the feed link in the comment' do
      expect(comment).to match "Feed Link: #{subject.feedlink}"
    end
  end

  context 'if it\'s an inquiry' do
    subject(:feedback_mail) { FactoryGirl.build(:feedback_mail, :note_type => 'inquiry') }
    it{ should validate_presence_of :inquiry }
  end

  context 'when saving' do
    before do
      FeedbackMailer.should_receive(:feedback).and_return(double('MockDeliverable',:deliver! => true))
    end
    it 'sends an email' do
      subject.save
    end
  end
end

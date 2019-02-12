# frozen_string_literal: true

require 'rails_helper'

describe FeedbackMail, type: :model do
  let(:feedback_params) { FactoryBot.attributes_for(:feedback_mail) }
  subject(:feedback_mail) { FactoryBot.build(:feedback_mail) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :email_confirm }
  it { should validate_presence_of :note_type }
  it do
    test_value = Shoulda::Matchers::ActiveModel::ValidateInclusionOfMatcher::ARBITRARY_OUTSIDE_STRING
    should validate_inclusion_of(:note_type)
      .in_array(FeedbackMail::VALID_NOTE_TYPES)
      .with_message("#{test_value} is not a valid note type")
  end

  context "if emails don't match (and are required" do
    subject(:feedback_mail) do
      FactoryBot.build(:feedback_mail,
                       email: 'jon@here.com',
                       email_confirm: 'joe@here.com')
    end
    it { should_not be_valid }
    it 'includes the errors on base' do
      subject.valid?
      expect(subject.errors[:base].join).to include 'reconfirm your email'
    end
  end

  context "if it's an inquiry" do
    subject(:feedback_mail) { FactoryBot.build(:feedback_mail, note_type: 'inquiry') }
    it { should validate_presence_of :inquiry }
  end

  context 'when saving' do
    before do
      expect(FeedbackMailer).to receive(:feedback).and_return(double('MockDeliverable', deliver_later: true))
    end
    it 'sends an email' do
      subject.save
    end
  end
end

require 'active_model'

class FeedbackMail
  include ActiveModel::Model

  attr_accessor :note_type,
                :email,
                :email_confirm,
                :question,
                :current_user,
                :operating_system,
                :browser,
                :device

  VALID_NOTE_TYPES = %w[help inquiry feedback secretWord].freeze

  validates :note_type,
            presence: true,
            inclusion: {
              in: VALID_NOTE_TYPES,
              message: '%{value} is not a valid note type',
            }

  validates :email, presence: true
  validates :email_confirm, presence: true

  validates :question, presence: true

  validate :emails_must_match

  def os=(value)
    self.operating_system = value
  end

  def emails_must_match
    errors.add(:base, "Please reconfirm your email. The emails don't match.") unless email == email_confirm
  end

  def subject
    @subject ||= "MAU Submit Form : #{note_type}"
  end

  def login
    @login ||=
      current_user.try(:login) || 'anon'
  end

  def account?
    !!current_user
  end

  def comment
    @comment ||=
      [].tap do |comment|
        comment << "OS: #{operating_system}"
        comment << "Browser: #{browser}"
        comment << "Device: #{device}"
        comment << "From: #{email}"
        comment << "Question: #{question}"
      end.join("\n")
  end

  def account_email
    "#{login} (account email : #{current_user.email})"
  end

  def save
    return false unless valid?

    em = (account? ? account_email : email)
    f = Feedback.new(email: em,
                     subject:,
                     login:,
                     comment:)
    success = f.save
    if success
      if note_type == 'secretWord'
        SignUpSupportMailer.secret_word_request(f).deliver_later
      else
        FeedbackMailer.feedback(f).deliver_later
      end
    end
    success
  end
end

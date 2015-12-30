require 'active_model'

class FeedbackMail

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :note_type, :email, :email_confirm,
    :inquiry, :current_user, :operating_system, :browser, :device


  VALID_NOTE_TYPES = %w(help inquiry)

  validates :note_type, :presence => true, :inclusion => { :in => VALID_NOTE_TYPES,
    :message => "%{value} is not a valid note type" }

  validates :email, :presence => true
  validates :email_confirm, :presence => true

  validates :inquiry, :presence => true

  validate :emails_must_match

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def os=(v)
    self.operating_system=v
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

  def has_account?
    !!(current_user)
  end

  def comment
    @comment ||=
      begin
        [].tap do |comment|
          comment << "OS: #{operating_system}"
          comment << "Browser: #{browser}"
          comment << "Device: #{device}"
          comment << "From: #{email}"
          comment << "Question: #{inquiry}"
        end.join("\n")
      end
  end

  def account_email
    "#{login} (account email : #{current_user.email})"
  end

  def save
    em = (has_account? ? account_email : email)
    f = Feedback.new( { :email => em,
                        :subject => subject,
                        :login => login,
                        :comment => comment })
    if f.save
      FeedbackMailer.feedback(f).deliver_now
    end
  end

end

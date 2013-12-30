require 'active_model'

class FeedbackMail

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :note_type, :email, :email_confirm, 
    :feedlink, :inquiry, :current_user, :operating_system, :browser
  

  VALID_NOTE_TYPES = %w(feed_submission help inquiry email_list)

  validates :note_type, :presence => true, :inclusion => { :in => VALID_NOTE_TYPES,
    :message => "%{value} is not a valid note type" }  
  
  validates :email, :presence => true, :unless => :is_a_feed_submission?
  validates :email_confirm, :presence => true, :unless => :is_a_feed_submission?

  validates :feedlink, :presence => true, :if => :is_a_feed_submission?

  validates :inquiry, :presence => true, :if => :is_an_inquiry?

  validate :emails_must_match

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def emails_must_match
    errors.add(:base, "Please reconfirm your email. The emails don't match.") unless email == email_confirm
  end

  def is_a_feed_submission?
    @is_a_feed_submission ||= (note_type == 'feed_submission')
  end

  def is_an_inquiry?
    @is_an_inquiry ||= (note_type == 'inquiry')
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
          case note_type
          when 'inquiry', 'help'
            comment << "From: #{email}"
            comment << "Question: #{inquiry}"
          when 'email_list'
            comment << "From: #{email}"
            comment << "Add me to your email list"
          when 'feed_submission'
            comment << "Feed Link: #{feedlink}"
          end
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
      FeedbackMailer.feedback(f).deliver!
    end
  end

end

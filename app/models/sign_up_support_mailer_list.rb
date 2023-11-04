class SignUpSupportMailerList < EmailList
  def self.instance
    first || create
  end
end

class RecruitingMailerList < EmailList
  def self.instance
    first || create
  end
end

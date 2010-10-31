class MAUFan < User
  def self.all
    return self.find(:all)
  end
end

class UpdateEmailAttrsForAllUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      new_settings = u.emailsettings
      ['mauadmin','maunews'].each{|k| new_settings.delete k}
      new_settings['fromall'] = true
      u.emailsettings = new_settings
      u.save
    end
  end

  def self.down
  end
end

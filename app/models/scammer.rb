require 'net/http'
require 'uri'

class Scammer < ActiveRecord::Base
  validates_uniqueness_of   :faso_id

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk

  def self.importFromFASO
    importer = FasoImporter.new
    importer.scammers.each do |s|
      s.save if s.valid?
    end
  end
end

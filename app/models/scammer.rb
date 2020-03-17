# frozen_string_literal: true

require 'net/http'
require 'uri'

class Scammer < ApplicationRecord
  validates :faso_id, uniqueness: { case_sensitive: false }

  validates :email, presence: true
  validates :email, length: { within: 6..100 } # r@a.wk

  def self.import_from_faso
    importer = FasoImporter.new
    importer.scammers.each do |s|
      next if Scammer.exists?(faso_id: s.faso_id)

      s.save if s.valid?
    end
  end
end

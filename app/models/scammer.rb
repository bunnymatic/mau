# frozen_string_literal: true
require 'net/http'
require 'uri'

class Scammer < ApplicationRecord
  validates   :faso_id, uniqueness: true

  validates :email, presence: true
  validates :email, length: { within: 6..100 } # r@a.wk

  def self.import_from_faso
    importer = FasoImporter.new
    importer.scammers.each do |s|
      s.save if s.valid?
    end
  end
end

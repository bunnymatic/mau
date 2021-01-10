# frozen_string_literal: true

class Medium < ApplicationRecord
  has_many :art_pieces, dependent: :nullify, inverse_of: :medium

  include FriendlyId
  friendly_id :name, use: [:slugged]

  validates :name, presence: true, length: { within: (2..244) }

  scope :alpha, -> { order(:name) }

  def hashtag
    return name.parameterize.underscore unless /^painting/i.match?(name)

    name.split('-').map(&:strip).reverse.join.downcase
  end

  def self.options_for_select
    [['None', 0]] + Medium.all.map { |u| [u.name, u.id] }
  end

  def self.by_name
    order(:name)
  end
end

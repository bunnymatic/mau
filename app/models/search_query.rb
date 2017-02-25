# frozen_string_literal: true
class SearchQuery
  PER_PAGE = 12

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :mediums, :studios, :keywords, :studios, :os_flag, :page, :mode, :per_page, :limit

  def initialize(attributes={})
    self.studios = set_studios(attributes[:studios]) || []
    self.mediums = set_mediums(attributes[:mediums]) || []
    self.keywords = (attributes[:keywords] || '').split(",").map(&:strip) || []
    self.os_flag = { '1' => true, '2' => false }[attributes[:os_artist]]
    self.page = attributes[:p].to_i
    self.mode = attributes[:m]
    self.per_page = (attributes[:per_page].present? ? attributes[:per_page] : PER_PAGE).to_i
    self.limit = (attributes[:limit] || -1).to_i
  end

  def query
    @query ||= @keywords.compact.join(", ")
  end

  def empty?
    !([studios, mediums, keywords, os_flag].any?(&:present?))
  end

  private

  def set_mediums(vals)
    return [] unless vals
    medium_ids = vals.map(&:to_i).reject{|v| v <= 0}
    Medium.by_name.where(id: medium_ids)
  end

  def set_studios(vals)
    return [] unless vals
    Studio.where(id: vals.compact.uniq)
  end
end

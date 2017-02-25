# frozen_string_literal: true
module TagsHelper
  def tags_to_s(tags)
    (tags.collect(&:name).uniq).join(', ')
  end
end

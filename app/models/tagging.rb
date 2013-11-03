# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  tag_id        :integer          not null
#  taggable_id   :integer          not null
#  taggable_type :string(255)      not null
#
# Indexes
#
#  index_taggings_on_tag_id_and_taggable_id_and_taggable_type  (tag_id,taggable_id,taggable_type) UNIQUE
#

class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true

  before_destroy :prevent_orphan_tags

  def prevent_orphan_tags
    # disallow orphaned tags
    tag.destroy_without_callbacks if tag.taggings.count < 2
  end
end

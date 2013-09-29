class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true

  before_destroy :prevent_orphan_tags

  def prevent_orphan_tags
    # disallow orphaned tags
    tag.destroy_without_callbacks if tag.taggings.count < 2
  end
end

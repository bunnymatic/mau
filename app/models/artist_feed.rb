class ArtistFeed < ActiveRecord::Base

  named_scope :active, :conditions => ['(active != false)']

  validates_presence_of :url
  validates_presence_of :feed
  validates_length_of :url, :within => 5..255
  validates_length_of :feed, :within => 5..255
  validates_uniqueness_of :feed

  def active?
    return self.active.present?
  end

end

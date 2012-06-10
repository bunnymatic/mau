class ApplicationEvent < ActiveRecord::Base
  # do not use this class directly, but use one of its derivations
  validates_presence_of :type
  validates_length_of :type, :minimum => 2
  default_scope :order => 'created_at desc'
  serialize :data, Hash
end

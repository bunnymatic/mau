require 'htmlhelper'

class Tag < ActiveRecord::Base
  has_many :art_pieces_tags
  has_many :art_pieces, :through => :art_pieces_tags

  after_save :flush_cache
  after_update :flush_cache
  after_destroy :flush_cache

  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..25

  # class level constants
  @@CACHE_EXPIRY =  (Conf.cache_expiry['objects'] or 0)
  @@TAGS_KEY = (Conf.cache_ns or '') + 'tags'
  @@MAX_SHOW_TAGS = 40

  def self.frequency
    tags = []
    dbr = connection.execute("/* hand generated sql */ Select tag_id tag,count(*) ct from art_pieces_tags where art_piece_id in (select id from art_pieces) group by tag_id order by ct desc;")
    dbr.each_hash{ |row| tags << row }
    result = tags[0..@@MAX_SHOW_TAGS]
  end

  def self.keyed_frequency
    # return frequency of tag usage keyed by tag id
    tags = []
    dbr = connection.execute("/* hand generated sql */ select tag_id tag,count(*) ct from art_pieces_tags group by tag_id;")
    # return sorted by freq
    keyed = {}
    dbr.each_hash do |row|
      keyed[ row['tag'] ] = row['ct']
    end
    keyed
  end


  def self.all
    begin
      tags = CACHE.get(@@TAGS_KEY)
    rescue
      logger.warn("Tag: Memcache seems to be dead")
      tags = nil
    end
    if ! tags
      logger.debug("Tag: Fetching from db")
      tags = super(:order => 'name')
      begin
        CACHE.set(@@TAGS_KEY, tags, @@CACHE_EXPIRY)
      rescue
        logger.warn("Tag: Failed to set tags in cache")
      end
    else
      logger.debug("Tag: fetch from cache")
    end
    tags
  end

  def safe_name
    HTMLHelper.encode(self.name).gsub(' ', '&nbsp;')
  end
  
  protected
  def flush_cache
    logger.debug "Tag: Flushing cache"
    begin
      CACHE.delete(@@TAGS_KEY)
    rescue
      logger.warn("Tag: Memcache delete failed")
    end
  end

end

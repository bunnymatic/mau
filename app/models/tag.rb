require 'htmlhelper'

class Tag < ActiveRecord::Base
  has_many :art_pieces_tags
  has_many :art_pieces, :through => :art_pieces_tags

  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..25

  # class level constants
  @@MAX_SHOW_TAGS = 80

  def self.frequency(normalize=true)
    tags = []
    dbr = connection.execute("/* hand generated sql */ Select tag_id tag,count(*) ct from art_pieces_tags where art_piece_id in (select id from art_pieces) group by tag_id order by ct desc;")
    dbr.each_hash{ |row| tags << row }    
    # compute max/min ct
    maxct = nil
    minct = nil
    tags.each do |t|
      if maxct == nil || maxct < t['ct'].to_i
        maxct = t['ct'].to_f
      end
    end  
    if maxct <= 0
      maxct = 1
    end
    if normalize
      tags.each do |t|
        t['ct'] = t['ct'].to_f / maxct.to_f
      end
    end
    tags[0..@@MAX_SHOW_TAGS]
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
    logger.debug("Tag: Fetching from db")
    super(:order => 'name')
  end

  def safe_name
    HTMLHelper.encode(self.name).gsub(' ', '&nbsp;')
  end
  
end

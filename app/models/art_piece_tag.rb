require 'htmlhelper'

class ArtPieceTag < ActiveRecord::Base
  include TagMediaMixin

  has_many :art_pieces, :through => :art_pieces_tags

  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..25

  # class level constants
  @@MAX_SHOW_TAGS = 80
  @@CACHE_KEY = 'tagfreq'
  @@CACHE_EXPIRY = Conf.cache_expiry['tag_frequency'] || 300

  def self.flush_cache
    Rails.cache.delete(@@CACHE_KEY + true.to_s)
    Rails.cache.delete(@@CACHE_KEY + false.to_s)
  end

  def self.frequency(normalize=true)
    freq = Rails.cache.read(@@CACHE_KEY + normalize.to_s)
    if freq
      logger.debug('read tag frequency from cache')
      return freq
    end
    tags = []
    dbr = connection.execute("/* hand generated sql */ Select art_piece_tag_id tag,count(*) ct from art_pieces_tags where art_piece_id in (select id from art_pieces) group by art_piece_tag_id order by ct desc;")
    dbr.map{|row| Hash[ 'tag', row[0], 'ct', row[1] ]}.each{ |row| tags << row }    
    # compute max/min ct
    maxct = nil
    minct = nil
    tags.each do |t|
      if maxct == nil || maxct < t['ct'].to_i
        maxct = t['ct'].to_f
      end
    end  
    if !maxct || maxct <= 0
      maxct = 1
    end
    if normalize
      tags.each do |t|
        t['ct'] = t['ct'].to_f / maxct.to_f
      end
    else
      tags.map {|t| t['ct'] = t['ct'].to_i}
    end
    Rails.cache.write(@@CACHE_KEY, tags[0..@@MAX_SHOW_TAGS], :expires_in => @@CACHE_EXPIRY)
    tags[0..@@MAX_SHOW_TAGS]

  end

  def self.keyed_frequency
    # return frequency of tag usage keyed by tag id
    tags = []
    dbr = connection.execute("/* hand generated sql */ select art_piece_tag_id tag,count(*) ct from art_pieces_tags group by art_piece_tag_id;")
    # return sorted by freq
    keyed = {}
    dbr.each do |rowarr|
      row = Hash[ 'tag', rowarr[0], 'ct', rowarr[1] ]
      keyed[ row['tag'] ] = row['ct']
    end
    keyed
  end


  def self.all
    logger.debug("ArtPieceTag: Fetching from db")
    super(:order => 'name')
  end

end

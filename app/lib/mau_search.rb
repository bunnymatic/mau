class MauSearch

  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end


  def search
    results_by_kw = {}

    if opts.keywords.length > 0
      results_by_kw = fetch_results_by_keyword(opts.keywords)
    else
      # if only medium search by art piece
      if opts.mediums.present? && !opts.studios.present?
        results_by_kw['by_medium'] = ArtPiece.where(:medium_id => opts.mediums.map(&:id))
      end
      # else search by artists in studios then narrow by mediums
      if opts.studios.present?
        results_by_kw['by_studio'] = Artist.where(:studio_id => opts.studios.map(&:id)).map(&:art_pieces).flatten
      end
    end

    partial_results = results_by_kw.values.compact.flatten

    partial_results = filter_results(partial_results, opts)

    results = {}
    begin
      partial_results.flatten.compact.flatten.each do |entry|
        results[entry.id] = entry if entry.id and entry.artist && entry.artist.active?
      end
    rescue Exception => ex
      logger.warn("Failed to map search results %s" % ex)
    end
    
    results.values.sort_by { |p| p.updated_at }

  end

  private
  def fetch_results_by_keyword(keywords)
    results = {}
    keywords.map(&:downcase).each do |kw|
      
      kw_query_param = "%#{kw}%"
      partial_results = ArtPiece.where(["title like ?", kw_query_param])
      partial_results += (Artist.active.where(["(firstname like ? or lastname like ? or lower(nomdeplume) like ?) ", kw_query_param, kw_query_param, kw_query_param ])).map{ |a| a.art_pieces }.flatten
      
      tag_ids = ArtPieceTag.where(:name => kw)
      tags = ArtPiecesTag.where(:art_piece_tag_id => tag_ids)
      partial_results += ArtPiece.where(:id => tags.map(&:art_piece_id) )
      
      media_ids = Medium.where(:name => kw)
      partial_results += ArtPiece.where(:medium_id => media_ids)
      
      partial_results += Artist.where(['lower(concat(trim(firstname), \' \', trim(lastname))) = ?', kw]).map(&:art_pieces).flatten
      
      results[kw] = partial_results.uniq_by{|obj| obj.id}
    end
    results
  end

  def filter_results(results, opts)

    # if there are not enough keyword hits
    hits = histogram results.map(&:id)
    num_keywords = opts.keywords.size
    results.reject!{|ap| hits[ap.id] < num_keywords}

    # filter by mediums and or studios
    if opts.mediums.present?
      mids = opts.mediums.map(&:id)
      results.reject!{|ap| !ap.medium_id || !mids.include?(ap.medium_id) }
    end
    if opts.studios.present?
      sids = opts.studios.map(&:id).compact
      results.reject!{|ap| !ap.artist || !sids.include?(ap.artist.studio_id)}
    end
    if opts.os_flag == true
      results.reject!{|ap| !ap.artist.doing_open_studios?}
    elsif opts.os_flag == false
      results.reject!{|ap| ap.artist.doing_open_studios?}
    end

    results
  end

end

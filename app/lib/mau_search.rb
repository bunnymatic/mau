class MauSearch

  attr_reader :keywords, :studios, :mediums, :os_flag

  def initialize(opts)
    @keywords = opts.keywords.map{|k| k.downcase.strip}.compact.uniq
    @os_flag = opts.os_flag
    @mediums = opts.mediums
    @studios = opts.studios

  end

  def keyword_count
    @kw_count ||= keywords.length
  end

  def search
    results_by_kw = {}

    if keyword_count > 0
      results_by_kw = fetch_results_by_keyword
    else
      # if only medium search by art piece
      if mediums.present? && !studios.present?
        results_by_kw['by_medium'] = ArtPiece.where(:medium_id => mediums.map(&:id))
      end
      # else search by artists in studios then narrow by mediums
      if studios.present?
        results_by_kw['by_studio'] = Artist.where(:studio_id => studios.map(&:id)).map(&:art_pieces).flatten
      end
    end

    partial_results = results_by_kw.values.compact.flatten

    partial_results = filter_results(partial_results)

    results = {}

    partial_results.flatten.compact.flatten.each do |entry|
      results[entry.id] = entry if entry.id and entry.artist && entry.artist.active?
    end

    results.values.sort_by { |p| p.updated_at }

  end

  private
  def sql_like_query_param(kw)
    "%#{kw}%"
  end

  def matches_by_partial_artist_name(kw)
    kw_query = sql_like_query_param(kw)
    query_params = [kw_query]*3
    clause = '(firstname like ? or lastname like ? or lower(nomdeplume) like ?)'
    artists = Artist.active.where([clause, query_params].flatten)
    artists.map(&:art_pieces).flatten
  end

  def matches_by_artist_full_name(kw)
    clause = 'lower(concat(trim(firstname), \' \', trim(lastname))) = ?'
    Artist.where([clause, kw]).map(&:art_pieces).flatten
  end

  def matches_by_title(kw)
    kw_query = sql_like_query_param(kw)
    ArtPiece.where(["title like ?", kw_query])
  end

  def matches_by_media(kw)
    media_ids = Medium.where(:name => kw)
    ArtPiece.where(:medium_id => media_ids)
  end

  def matches_by_tags(kw)
    tag_ids = ArtPieceTag.where(:name => kw)
    tags = ArtPiecesTag.where(:art_piece_tag_id => tag_ids)
    ArtPiece.where(:id => tags.map(&:art_piece_id) )
  end

  def fetch_results_by_keyword
    {}.tap do |results|
      keywords.each do |kw|
        results[kw] = [ matches_by_title(kw),
                        matches_by_partial_artist_name(kw),
                        matches_by_tags(kw),
                        matches_by_media(kw),
                        matches_by_artist_full_name(kw) ].flatten.uniq_by(&:id)
      end
    end
  end

  def filter_results(results)

    # if there are not enough keyword hits
    hits = histogram results.map(&:id)
    results.reject!{|ap| hits[ap.id] < keyword_count}

    # filter by mediums and or studios
    if mediums.present?
      mids = mediums.map(&:id)
      results.reject!{|ap| !ap.medium_id || !mids.include?(ap.medium_id) }
    end
    if studios.present?
      sids = studios.map(&:id).compact
      results.reject!{|ap| !ap.artist || !sids.include?(ap.artist.studio_id)}
    end
    if os_flag == true
      results.reject!{|ap| !ap.artist.doing_open_studios?}
    elsif os_flag == false
      results.reject!{|ap| ap.artist.doing_open_studios?}
    end

    results
  end

end

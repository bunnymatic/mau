class SearchService

  attr_reader :query
  delegate :os_flag, :mediums, :studios, :to => :query

  def initialize(query)
    @query = query
  end

  def keywords
    @keywords = query.keywords.map{|k| k.downcase.strip}.compact.uniq
  end

  def medium_ids
    @medium_ids ||= mediums.map(&:id)
  end

  def studio_ids
    @studio_ids ||= studios.map(&:id)
  end

  def has_keywords
    keywords.present?
  end

  def keyword_count
    @kw_count ||= keywords.length
  end

  def fetch_results_by_medium_or_studio
    # if only medium search by art piece
    return {'by_medium' => art_pieces_by_medium} if (mediums.present? && !studios.present?)
    # else search by artists in studios then narrow by mediums
    return {'by_studio' => art_pieces_by_studio} if studios.present?
  end

  def search
    results_by_kw = if has_keywords
                      fetch_results_by_keyword
                    else
                      fetch_results_by_medium_or_studio
                    end || {}
    partial_results = filter_results(results_by_kw)

    results = {}
    partial_results.each do |entry|
      results[entry.id] = entry if entry.id and entry.artist && entry.artist.active?
    end

    (results.values.sort_by { |p| p.updated_at })[0..(@query.limit || -1)]
  end

  private
  def sql_like_query_param(kw)
    "%#{kw}%"
  end

  def matches_by_partial_artist_name(kw)
    kw_query = sql_like_query_param(kw)
    query_params = [kw_query]*3
    clause = '(firstname like ? or lastname like ? or lower(nomdeplume) like ?)'
    artist_list = artists.where([clause, query_params].flatten)
    artist_list.map(&:art_pieces).flatten
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

  def artists
    @artists ||= Artist.active
  end

  def art_pieces_by_studio
    @art_pieces_by_studio ||=
      begin
        r = artists.where(:studio_id => studio_ids).map(&:art_pieces).flatten
        if (studio_ids.include? 0)
          r += artists.where('studio_id is null').map(&:art_pieces).flatten
        end
        r
      end
  end

  def art_pieces_by_medium
    @art_pieces_by_medium ||= ArtPiece.where(:medium_id => medium_ids)
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

  def filter_results(results_by_kw)
    results = results_by_kw.values.compact.flatten

    hits = StatsCalculator.histogram results.map(&:id)
    results.reject!{|ap| hits[ap.id] < keyword_count}

    results = filter_by_medium(results)
    results = filter_by_studios(results)
    filter_by_os_flag(results).flatten.compact
  end

  def filter_by_medium(results)
    # filter by mediums and or studios
    mediums.present? ? results.reject{|ap| !ap.medium_id || !medium_ids.include?(ap.medium_id) } : results
  end

  def filter_by_studios(results)
    if studios.present?
      results.select do |ap|
        ap.artist && (studio_ids.include?(ap.artist.studio_id) || ((studio_ids.include? 0) && ap.artist.studio.nil?))
      end
    else
      results
    end
  end

  def filter_by_os_flag(results)
    case os_flag
    when true
      results.reject{|ap| !ap.artist.doing_open_studios?}
    when false
      results.reject{|ap| ap.artist.doing_open_studios?}
    else
      results
    end
  end

end

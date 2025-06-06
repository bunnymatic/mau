module Admin
  class StatsController < ::BaseAdminController
    def art_pieces_per_day
      apd = compute_art_pieces_per_day
      render json: format_for_graph(apd)
    end

    def favorites_per_day
      fpd = compute_favorites_per_day
      render json: format_for_graph(fpd)
    end

    def artists_per_day
      apd = compute_artists_per_day
      render json: format_for_graph(apd)
    end

    def user_visits_per_day
      upd = compute_user_visits_per_day
      render json: format_for_graph(upd)
    end

    def art_pieces_count_histogram
      appa = compute_art_piece_count_histogram
      render json: format_for_graph(appa)
    end

    def os_signups
      tally = OpenStudiosTally.where(oskey: OpenStudiosEventService.current&.key)
      tally = tally.map { |t| [t.recorded_on.to_datetime.to_i, t.count] }
      render json: format_for_graph(tally)
    end

    GRAPH_LOOKBACK = '1 YEAR'.freeze

    private

    def format_for_graph(data)
      data.to_json
    end

    def compute_art_piece_count_histogram
      sql = <<-SQL.squish
        select bucket, count(*) as ct
        from (
           select count(*) as bucket
           from art_pieces ap, users a
           where a.state='#{Constants::User::STATE_ACTIVE}' and a.id=ap.artist_id
           group by ap.artist_id) as tmp
        group by bucket;
      SQL
      results = ActiveRecord::Base.connection.execute(sql)
      results_by_num_pieces = {}
      results.each do |row|
        results_by_num_pieces[row.first] = row.last
      end
      Array.new(Artist::MAX_PIECES + 1) do |x|
        [x, results_by_num_pieces[x] || 0]
      end
    end

    def compute_artists_per_day
      cur = Artist.active
                  .where("adddate(activated_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()")
                  .group('date(activated_at)')
                  .order(Arel.sql('date(activated_at) desc')).count
      cur.select { |k, _v| k.present? }.map { |k, v| [k.to_datetime, v].map(&:to_i) }
    end

    def compute_user_visits_per_day
      cur = User.where("adddate(last_request_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()")
                .group('date(last_request_at)')
                .order(Arel.sql('date(last_request_at) desc')).count
      cur.select { |k, _v| k.present? }.map { |k, v| [k.to_datetime, v].map(&:to_i) }
    end

    def compute_favorites_per_day
      compute_created_per_day Favorite
    end

    def compute_art_pieces_per_day
      compute_created_per_day ArtPiece
    end

    def compute_created_per_day(clz)
      cur = clz.where("adddate(created_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()")
               .group('date(created_at)')
               .order(Arel.sql('date(created_at) desc')).count
      cur.select { |k, _v| k.present? }.map { |k, v| [k.to_datetime, v].map(&:to_i) }
    end
  end
end

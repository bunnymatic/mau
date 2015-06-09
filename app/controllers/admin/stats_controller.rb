module Admin
  class StatsController < AdminController

    def art_pieces_per_day
      apd = compute_art_pieces_per_day
      result = { :series => [ { :data => apd }],
                 :options => {
                   :mouse => { :track => true }
                 }
               }
      render :json => result
    end

    def favorites_per_day
      apd = compute_favorites_per_day
      result = { :series => [ { :data => apd }],
                 :options => {
                   :mouse => { :track => true }
                 }
               }
      render :json => result
    end

    def artists_per_day
      apd = compute_artists_per_day
      result = { :series => [ { :data => apd }],
                 :options => {
                   :mouse => { :track => true }
                 }
               }
      render :json => result
    end

    def logins_per_day
      lpd = compute_logins_per_day
      result = { :series => [ { :data => lpd }],
                 :options => {
                   :mouse => { :track => true }
                 }
               }
      render :json => result
    end
    
    def os_signups
      tally = OpenStudiosTally.where(:oskey => current_open_studios_key)
      tally = tally.map{|t| [ t.recorded_on.to_time.to_i, t.count ]}

      result = { :series => [{ :data => tally }],
                 :options => {
                   :mouse => { :track => true }
                 }
               }
      render :json => result
    end
    
    GRAPH_LOOKBACK = '1 YEAR'
      
    def compute_artists_per_day
      cur = Artist.active.
            where("adddate(activated_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()").
            group("date(activated_at)").
            order("activated_at desc").count
      cur.select{|k,v| k.present?}.map{|k,v| [k.to_time, v].map(&:to_i)}
    end

    def compute_logins_per_day
      cur = User.where("adddate(current_login_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()").
            group("date(current_login_at)").
            order("current_login_at desc").count
      cur.select{|k,v| k.present?}.map{|k,v| [k.to_time, v].map(&:to_i)}
    end

    def compute_favorites_per_day
      compute_created_per_day Favorite
    end

    def compute_art_pieces_per_day
      compute_created_per_day ArtPiece
    end

    def compute_created_per_day(clz)
      cur = clz.where("adddate(created_at, INTERVAL #{GRAPH_LOOKBACK}) > NOW()").
            group("date(created_at)").
            order("created_at desc").count
      cur.select{|k,v| k.present?}.map{|k,v| [k.to_time, v].map(&:to_i)}
    end

  end

  
end

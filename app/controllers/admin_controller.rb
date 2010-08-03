class AdminController < ApplicationController
  before_filter :admin_required
  def index
    render :text => "Nothing to see here.  Please move along."
  end
  
  def stats
    render :text => "<html><body>%s Artists<br/>%s ArtPieces<br/></body></html>" % [ Artist.count, ArtPiece.count ]
  end

  def artists_per_day
    sql = ActiveRecord::Base.connection()
    @tbl = []
    cur = sql.execute "select count(*) ct,date(activated_at) d from artists group by d order by d desc;"
    ctr = 0
    cur.each_hash do |h|
      @tbl << [h['ct'],h['d']]
    end
    @numrows = @tbl[-1][0].to_i
    @tbl.delete_at(-1)
    
  end

  def email_artists
    render :text => 'build this out'
  end
end

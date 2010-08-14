class AdminController < ApplicationController
  before_filter :admin_required
  def index
    render :text => "Nothing to see here.  Please move along."
  end
  
  def stats
    activated = Artist.count(:conditions => "state='active'")
    accounts = Artist.count
    artpieces = ArtPiece.count
    introuble = Artist.count(:conditions => "state='pending'")
    noprofile = Artist.count(:conditions => "state='active' and profile_image is not null")

    sql = ActiveRecord::Base.connection()
    query = "select count(*) ct from artists where id not in (select distinct artist_id from art_pieces);"

    noimages = []
    cur = sql.execute query
    cur.each_hash do |h|
      noimages << h['ct']
    end
    p noimages
    str = ""
    str += "<div>Total Accounts: %s</div>" % accounts
    str += "<div>Activated : %s</div>" % activated
    str += "<div>ArtPieces : %s</div>" % artpieces
    str += "<div>Artists pending (not yet activated) : %s</div>" % introuble
    str += "<div>No Profile Image : %s</div>" % noprofile
    str += "<div>No uploaded image : %s</div>" % noimages
    render :text => "<html><body>%s</body></html>" % str
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

  def 
  def email_artists
    render :text => 'build this out'
  end
end

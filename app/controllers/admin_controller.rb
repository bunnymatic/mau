class AdminController < ApplicationController
  before_filter :admin_required
  def index
    render :text => "Nothing to see here.  Please move along."
  end

  def admin_emails
    @artists = Artist.find(:all, :conditions => ['state="active"'])
  end

  def emaillist
    artists = []
    arg = params[:listname]
    case arg
    when 'activated'
      @title = "All Activated Artsts"
      artists = Artist.find(:all, :conditions => [ "state='active'" ])
    when 'accounts'
      @title = "All Accounts - active, suspended, pending etc *ALL*"
      artists = Artist.find(:all)
    when 'pending'
      @title = "Not yet activated artists"
      artists = Artist.find(:all, :conditions => [ "state='pending'" ])
    when 'noprofile'
      @title = "Artists who haven't submitted a profile picture"
      artists = Artist.find(:all, :conditions => [ "state='active' and profile_image is null" ])
    when 'noimages'
      @title = "Artists who have not uploaded any images"
      sql = ActiveRecord::Base.connection()
      query = "select id from artists where id not in (select distinct artist_id from art_pieces);" 
      cur = sql.execute query
      aids = []
      cur.each_hash do |h|
        aids << h["id"]
      end
      print aids
      artists = Artist.find(:all, :conditions => { :id => aids })
    else
      @emails = []
      @msg = "I don't know what list you wanted?"
      @title = "All Activated Artsts"
      artists = Artist.find(:all, :conditions => [ "state='active'" ])
    end
    @emails = []
    artists.each do |a|
      entry = { :id => a.id, :name => a.get_name, :email => a.email }
      @emails << entry
    end

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
    
    d = {:accounts => { :name => "Total Accounts", :data => accounts },
      :activated => { :name => "Activated", :data => activated },
      :pending => { :name => "Pending (not yet activated)", :data => introuble },
      :noprofile => { :name => "No Profile Image", :data => noprofile },
      :noimages => { :name => "No Uploaded Art", :data => noimages }
    }

    @artpieces = artpieces
    @artiststats = d
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
    
    # format table into chunks of 7 days
    numperchunk = 20
    @chunks = []
    ctr = 1
    chunk = nil
    @tbl.each do |c, d|
      if ctr == 1
        chunk = []
      end
      if ctr <= numperchunk
        chunk << [c,d]
      end
      if ctr == numperchunk
        @chunks << chunk
        chunk = []
        ctr = 0
      end
      ctr+=1
    end
    if ctr < numperchunk and chunk and chunk.length > 0
      @chunks << chunk
    end
  end
end

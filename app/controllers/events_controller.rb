class EventsController < ApplicationController

  before_filter :user_required, :except => [:index, :show]
  before_filter :editor_required, :only => [:destroy]

  def index
    raw_events = Event.published.by_starttime.reverse
    events = EventsPresenter.new(view_context, raw_events, params['m'])

    respond_to do |format|
      format.html {
        @events = events
      }
      format.json  {
        render :json => raw_events
      }
      format.atom {
        @title = "MAU Events"
        # the news items
        @events = events

        # this will be our Feed's update timestamp
        @updated = @events.first.try(:updated_at)
        render :layout => false
      }
      # we want the RSS feed to redirect permanently to the ATOM feed
      format.rss { redirect_to events_path(:format => :atom), :status => :moved_permanently }
    end
  end

  def show
    event = Event.find(params[:id])
    @event = EventPresenter.new(view_context,event)
    @page_title = "MAU Event: %s" % @event.title
  end

  # GET /events/new
  def new
    @event = Event.new.decorate
    render 'new_or_edit'
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id]).decorate
    render 'new_or_edit'
  end

  # POST /events
  def create
    @event = Event.new(event_params(true))
    if @event.save
      EventMailer.event_added(@event).deliver!
      redirect_after_create
    else
      @event = @event.decorate
      render "new_or_edit"
    end
  end

  # PUT /events/1
  def update
    @event = Event.find(params[:id])
    event_details = event_params(false)
    if event_details[:artist_list]
      artist_list = event_details[:artist_list]
      event_details.delete :artist_list
    end

    if @event.update_attributes(event_details)
      flash[:notice] = 'Event was successfully updated.'
      redirect_to(admin_events_path)
    else
      @event = @event.decorate
      render "new_or_edit", :layout => 'admin'
    end
  end

  # DELETE /events/1
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to(events_url)
  end

  private
  def append_artists_to_description(event_info)
    if event_info[:artist_list]
      artist_list = event_info.delete(:artist_list)
      artist_names = artist_list.split(',')
      artists = fetch_artists_by_names(artist_names)
      links = artists.map{|a| "[#{a.get_name}](#{a.get_share_link})"}.join(', ')
      event_info[:description] << "\n\n" << links << "\n" if links.present?
    end
    event_info
  end

  def fetch_artists_by_names(names)
    names.map do |name|
      Artist.find_by_full_name(name)
    end.flatten.compact
  end

  def event_params(append_artist = false)
    info = params.require(:event).permit :title, :description, :tweet, :street,
                                         :venue, :state, :city, :zip,
                                         :start_date, :start_time,
                                         :end_date, :end_time,
                                         :reception_start_date, :reception_start_time,
                                         :reception_end_date, :reception_end_time,
                                         :url, :lat, :lng, :user_id, :artist_list,
                                         :reception_starttime, :reception_endtime

    # info = info
    info = append_artists_to_description(info) if append_artist
    info[:user_id] = current_user.id
    info[:starttime] = reconstruct_starttime(info)
    info[:reception_starttime] = reconstruct_reception_starttime(info)
    info[:endtime] = reconstruct_endtime(info)
    info[:reception_endtime] = reconstruct_reception_endtime(info)
    info
  end

  def reconstruct_starttime(info)
    reconstruct_time(info, :start_date, :start_time)
  end
  def reconstruct_reception_starttime(info)
    reconstruct_time(info, :reception_start_date, :reception_start_time)
  end
  def reconstruct_endtime(info)
    reconstruct_time(info, :end_date, :end_time)
  end
  def reconstruct_reception_endtime(info)
    reconstruct_time(info, :reception_end_date, :reception_end_time)
  end

  def reconstruct_time(info, date_key, time_key)
    begin
      datestr = [info.delete(date_key), info.delete(time_key)].join ' '
      Time.zone.parse(datestr)
    end
  end



  def redirect_after_create
    msg = 'Thanks for your submission.  As soon as we validate the data, we\'ll add it to this list.'
    redirect_to events_path, :flash => {:notice => msg}
  end
end

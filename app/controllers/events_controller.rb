class EventsController < ApplicationController
  include EventsHelper

  before_filter :login_required, :except => [:index, :show]
  before_filter :editor_required, :only => [:admin_index, :publish, :unpublish, :destroy]

  layout 'mau2col'

  def admin_index
    @events = Event.all

    render :layout => 'mau-admin'
  end

  # GET /events
  # GET /events.xml
  def index

    @events_by_month = Event.published.keyed_by_month
    @events = @events_by_month.values.map{|v| v[:events]}.flatten.sort_by(&:stime).reverse
    if params["m"] && (@events_by_month.keys.include? params["m"])
      @current = params["m"]
    end

    respond_to do |format|
      format.html {
        render :layout => 'mau'
      }
      format.mobile {
        # @events = Event.published.reverse
        @page_title = "MAU Events"
        render :layout => 'mobile'
      }
      format.json  {
        @events = Event.published
        render :json => @events
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    @page_title = "MAU Event: %s" % @event.title
    respond_to do |format|
      format.html
      format.mobile {
        render :layout => 'mobile'
      }
    end
  end

  # GET /events/new
  def new
    @event = Event.new(:state => 'CA', :city => 'San Francisco')
    render 'new_or_edit'
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    render 'new_or_edit'
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    if @event.save
      EventMailer.event_added(@event).deliver!
      redirect_after_create
    else
      render "new_or_edit"
    end
  end

  # PUT /events/1
  def update
    @event = Event.find(params[:id])
    event_details = params[:event]
    if event_details[:artist_list]
      artist_list = event_details[:artist_list]
      event_details.delete :artist_list
    end

    if @event.update_attributes(event_details)
      flash[:notice] = 'Event was successfully updated.'
      redirect_to(admin_events_path)
    else
      puts @event.errors.full_messages.join
      render "new_or_edit", :layout => 'mau-admin'
    end
  end

  # DELETE /events/1
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to(events_url)
  end

  def publish
    @event = Event.find(params[:id])
    if @event.update_attributes(:publish => Time.zone.now)
      flash[:notice] = "#{@event.title} has been successfully published."
      if (@event.user && @event.user.email)
        EventMailer.event_published(@event).deliver!
        flash[:notice] << " And we sent a notification email to #{@event.user.fullname} at #{@event.user.email}."
      end
    end

    redirect_to admin_events_path
  end

  def unpublish
    @event = Event.find(params[:id])
    if @event.update_attributes(:publish => nil)
      flash[:notice] = "#{@event.title} has been successfully unpublished."
    else
      flash[:error] = "There was a problem publishing #{@event.title}. " + (@event.errors.map{|e| e.join ' '}.join ',')
    end
    redirect_to admin_events_path
  end

  private
  def append_artists_to_description
    event_info = params[:event]
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
      name.strip!
      a = Artist.find_by_fullname(name.strip)
      if a.blank?
        a = Artist.find_by_login(name)
      end
      a
    end.flatten.compact
  end

  def event_params
    info = append_artists_to_description
    info[:user_id] = current_user.id
    info
  end

  def redirect_after_create
    msg = 'Thanks for your submission.  As soon as we validate the data, we\'ll add it to this list.'
    redirect_to events_path, :flash => {:notice => msg}
  end
end

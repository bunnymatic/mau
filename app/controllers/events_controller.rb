class EventsController < ApplicationController
  include EventsHelper

  before_filter :login_required, :except => [:index, :show]
  before_filter :admin_required, :only => [:admin_index, :publish, :unpublish]

  layout 'mau2col'

  def admin_index
    @events = Event.all

    respond_to do |format|
      format.html { render :layout => 'mau-admin' }
      format.xml  { render :xml => @events }
    end
  end

  # GET /events
  # GET /events.xml
  def index

    @events = Event.published
    @events_by_month = {}

    today = Time.now
    current_key = today.strftime('%Y%m')
    current_display = today.strftime('%B %Y')
    @events_by_month[current_key] = {:display => current_display, :events => [] }

    @events.each do |ev|
      month = ev.starttime.strftime('%B %Y')
      month_key = ev.starttime.strftime('%Y%m')
      @events_by_month[month_key] = {:display => month, :events => [] } unless @events_by_month.has_key? month_key
      @events_by_month[month_key][:events] << ev
    end
    
    respond_to do |format|
      format.html { 
        render :layout => 'mau'
      }
      format.mobile { 
        @events = Event.published
        @page_title = "MAU Events"
        render :layout => 'mobile'
      }
      format.xml  { 
        @events = Event.published
        render :xml => @events 
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
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
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
  # POST /events.xml
  def create
    event_details = params[:event]
    if event_details[:artist_list]
      artist_list = event_details[:artist_list]
      event_details.delete :artist_list
      artist_names = artist_list.split(',')
      artists = []
      artist_names.each do |n|
        n.strip!
        a = Artist.find_by_fullname(n)
        if !a || a.empty?
          a = Artist.find_by_login(n)
        end
        artists << a if a
      end
      event_details[:description] << "\n\n" << artists.flatten.map{|a| "[#{a.get_name}](#{a.get_share_link})"}.join(', ')
    end

    event_details[:user_id] = current_user.id
    @event = Event.new(event_details)
    
    respond_to do |format|
      if @event.save
        EventMailer.deliver_event_added(@event)
        redir = events_path
        flash[:notice] = 'Thanks for your submission.  As soon as we validate the data, we\'ll add it to this list.'
        format.html { redirect_to(redir) }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render "new_or_edit"}
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    event_details = params[:event]
    if event_details[:artist_list]
      artist_list = event_details[:artist_list]
      event_details.delete :artist_list
    end

    respond_to do |format|
      if @event.update_attributes(event_details)
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(admin_events_path) }
        format.xml  { head :ok }
      else
        format.html { render "new_or_edit", :layout => 'mau-admin' }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end

  def publish
    @event = Event.find(params[:id])
    if @event.update_attributes(:publish => Time.now())
      flash[:notice] = "#{@event.title} has been successfully published."
      if (@event.user && @event.user.email)
        EventMailer.deliver_event_published(@event)
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

end

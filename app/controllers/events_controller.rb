class EventsController < ApplicationController

  before_filter :login_required, :except => [:index]
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
    @events = Event.future.published

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new(:zip => '94110', :state => 'CA', :city => 'San Francisco')
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
    end
    @event = Event.new(event_details)

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Thanks for your submission.  As soon as we validate the data, we\'ll add it to this list.'
        format.html { redirect_to(events_path) }
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
        format.html { redirect_to(events_path) }
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
    end
    redirect_to events_path  
  end

  def unpublish
    @event = Event.find(params[:id])
    if @event.update_attributes(:publish => nil)
      flash[:notice] = "#{@event.title} has been successfully unpublished."
    else
      flash[:error] = "There was a problem publishing #{@event.title}. " + (@event.errors.map{|e| e.join ' '}.join ',')
    end
    redirect_to events_path
  end
end

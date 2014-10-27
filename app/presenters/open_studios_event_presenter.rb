class OpenStudiosEventPresenter

  attr_reader :model

  delegate :key, :logo, :logo?, :to => :model

  def initialize(view_context, os_event)
    @model = os_event
    @view_context = view_context
  end

  def title
    (available? && @model.title.present?) ? @model.title : "Open Studios"
  end

  def display_logo
    if(available? && logo?)
      logo.url(:square)
    else
      @view_context.image_path('mau-nextos.png')
    end
  end

  def available?
    !@model.nil?
  end

  def edit_path
    @view_context.edit_admin_open_studios_event_path(@model)
  end

  def destroy_path
    @view_context.admin_open_studios_event_path(@model)
  end

  def start_date
    model.start_date.strftime("%b %d, %Y")
  end

  def end_date
    model.end_date.strftime("%b %d, %Y")
  end

end

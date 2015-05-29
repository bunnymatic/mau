class StudiosPresenter

  include Enumerable
  attr_reader :view_mode

  def initialize(view_context, studios, view_mode)
    @view_context = view_context
    @studios = studios
    @view_mode = view_mode
  end

  def studios_by_count
    @studios_by_count ||= @studios.sort_by{|s| -s.artists.active.count}
  end

  def order_by_count?
    @view_mode == 'count'
  end

  def studios
    (if order_by_count?
       studios_by_count
     else
       @studios
     end).map{|s| StudioPresenter.new(@view_context, s)}
  end

end

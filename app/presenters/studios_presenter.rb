class StudiosPresenter
  include OsHelper

  include Enumerable
  attr_reader :view_mode

  def initialize(studios, view_mode)
    @studios = studios
    @view_mode = view_mode
  end

  def studios_by_count
    @studios_by_count ||= @studios.sort_by{|s| -s.active_artists.count}
  end

  def studios
    (@view_mode == 'count') ? studios_by_count : @studios
  end

  def each(&block)
    studios.each(&block)
  end

end

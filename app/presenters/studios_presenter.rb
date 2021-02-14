class StudiosPresenter
  include Enumerable
  attr_reader :view_mode

  def initialize(studios, view_mode = nil)
    @studios = studios
    @view_mode = view_mode
  end

  def studios
    @studios.map { |s| StudioPresenter.new(s) }
  end
end

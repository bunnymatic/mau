class StudioNavigation < Navigation

  def initialize(view_context)
    @view_context = view_context
  end

  def items
    @items ||=
      begin
        [].tap do |nav|
          nav << "<a title='groups studios' href='#{@view_context.studios_path}'>groups</a>"
          nav << "<a title='independent studios' href='#{@view_context.studio_path(0)}'>independents</a>"
          nav << "<a title='venues' href='#{@view_context.venues_path}'>venues</a>"
        end
      end
  end
end

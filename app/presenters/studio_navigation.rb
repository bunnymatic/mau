class StudioNavigation < Navigation

  def initialize(view_context)
    @view_context = view_context
  end

  def items
    @items ||=
      begin
        [].tap do |nav|
          nav << "<a title='group studios' href='#{@view_context.studios_path}'>group studios</a>"
          nav << "<a title='independent studios' href='#{@view_context.studio_path(0)}'>independent studios</a>"
          nav << "<a title='venues' href='#{@view_context.venues_path}'>venues</a>"
        end
      end
  end
end

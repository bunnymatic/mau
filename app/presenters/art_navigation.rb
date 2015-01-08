class ArtNavigation < Navigation

  attr_reader :current_user

  def initialize(view_context, user)
    @view_context = view_context
    @current_user = user
  end

  def items
    @items ||=
      begin
        [].tap do |items|
          items << link_to('add', @view_context.new_artist_art_piece_path(current_user))
          items << link_to('arrange', @view_context.arrange_art_artists_path)
          items << link_to('delete', @view_context.delete_art_artists_path)
        end
      end
  end

  private
  def link_to(*args)
    @view_context.link_to(*args)
  end

end

# frozen_string_literal: true
module FavoriteCreator
  def create_favorite( favoritee, favorite )
    Favorite.create( user_id: favoritee.id, favoritable_type: favorite.class.name, favoritable_id: favorite.id )
  end
end

RSpec.configure do |c|
  c.include FavoriteCreator
end

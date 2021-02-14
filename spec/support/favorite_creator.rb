module FavoriteCreator
  def create_favorite(owner, favorite)
    Favorite.create(owner_id: owner.id, favoritable_type: favorite.class.name, favoritable_id: favorite.id)
  end
end

RSpec.configure do |c|
  c.include FavoriteCreator
end

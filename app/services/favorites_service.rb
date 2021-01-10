# frozen_string_literal: true

class InvalidFavoriteTypeError < StandardError; end

class FavoritesService
  def self.get_object(type, id)
    type.constantize.find(id)
  end

  def self.add(user, obj)
    type, id = unpack_object(obj)
    raise InvalidFavoriteTypeError, "You can't favorite that type of object" unless Favorite::FAVORITABLE_TYPES.include? type

    clz = type.constantize
    clz.transaction do
      obj = clz.find(id)
      obj ? add_favorite(user, obj) : nil
    end
  end

  def self.remove(user, obj)
    type, id = unpack_object(obj)
    raise InvalidFavoriteTypeError, "You can't unfavorite that type of object" unless Favorite::FAVORITABLE_TYPES.include? type

    clz = type.constantize
    clz.transaction do
      obj = clz.find(id)
      (obj ? remove_favorite(user, obj) : nil)
    end
  end

  class << self
    private

    def unpack_object(obj)
      [obj.class.name, obj.id]
    end

    def notify_favorited_user(fav, sender)
      artist = fav.is_a?(User) ? fav : fav.artist
      begin
        ArtistMailer.favorite_notification(artist, sender).deliver_later if artist
      rescue Postmark::InvalidMessageError => e
        Rails.logger.error(sprintf('Failed to notify favorited user %s [%s]', fav.inspect, e.message))
      end
    end

    def remove_favorite(user, obj)
      # Don't convert to `favoritable: obj` because for Artists it get's class name `User`
      # making this query fail
      user.favorites.where(favoritable_type: obj.class.name, favoritable_id: obj.id).destroy_all
      obj
    end

    def add_favorite(owner, obj)
      # can't favorite yourself
      return if trying_to_favorite_yourself?(owner, obj)

      # Don't convert to `favoritable: obj` because for Artists it get's class name `User`
      # making this query fail
      #
      # don't add dups
      favorite_params = {
        favoritable_type: obj.class.name,
        favoritable_id: obj.id,
        owner_id: owner.id,
      }
      f = Favorite.create(favorite_params)
      notify_favorited_user(obj, owner) if f
      obj
    end

    def trying_to_favorite_yourself?(owner, obj)
      false if obj.nil?
      ((obj.is_a?(User) || obj.is_a?(Artist)) && obj.id == owner.id) ||
        (obj.is_a?(ArtPiece) && obj.artist.id == owner.id)
    end
  end
end

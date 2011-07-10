class InitializeFeaturedArtistQueue < ActiveRecord::Migration
  def self.up
    sql = "insert into featured_artist_queue(artist_id, position) (select id, rand() from users where type='Artist' and activated_at is not null and state='active')"
    execute sql
  end

  def self.down
  end
end

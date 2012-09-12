module ApplicationEventsHelper
  def link_to_user ev
    if ev.data && ev.data.has_key?('user')
      begin
        return link_to ev.data['user'], artist_path(:id => ev.data['user'])
      rescue
        return ev.data['user']
      end
    end
    ''
  end
end

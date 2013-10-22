module ApplicationEventsHelper
  def link_to_user ev
    if ev.data && ev.data.has_key?('user') && ev.data['user'].present?
      link_to ev.data['user'], artist_path(:id => ev.data['user'])
    else
      ''
    end
  end
end

module ApplicationEventsHelper
  def link_to_event_user(event)
    data = (event.data || {}).with_indifferent_access
    (link_to data['user'], artist_path(id: data['user_id']) if data['user'].present?).to_s
  end
end

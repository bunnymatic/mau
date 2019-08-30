# frozen_string_literal: true

module ApplicationEventsHelper
  def link_to_user(event)
    user = (event.data || {})['user']
    (link_to event.data['user'], artist_path(id: event.data['user']) if user.present?).to_s
  end
end

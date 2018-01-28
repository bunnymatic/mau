# frozen_string_literal: true

module ApplicationEventsHelper
  def link_to_user(ev)
    user = (ev.data || {})['user']
    (link_to ev.data['user'], artist_path(id: ev.data['user']) if user.present?).to_s
  end
end

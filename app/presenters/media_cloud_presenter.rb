# frozen_string_literal: true
class MediaCloudPresenter < ViewPresenter
  include TagsHelper

  attr_reader :frequency, :mode

  # medium is the selected one
  def initialize(media, selected, mode)
    @media = media
    @selected = selected
    @frequency = Medium.frequency(true)
    @mode = mode
  end

  def medium_path(medium)
    url_helpers.medium_path(medium, m: mode)
  end

  def find_medium(id)
    media_lut[id]
  end

  def media_lut
    @media_lut = Hash[Medium.all.map{|m| [m.id, m]}]
  end

  def media_for_display
    @media_for_display ||=
      begin
        frequency.map do |entry|
          medium = find_medium(entry['medium'])
          next unless medium
          content_tag 'span', class: 'clouditem' do
            link_to medium.safe_name, medium_path(medium)
          end
        end.select{|m| m.present?}
      end
  end
end

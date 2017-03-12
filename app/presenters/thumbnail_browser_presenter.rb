# frozen_string_literal: false
class ThumbnailBrowserPresenter < ViewPresenter
  include ApplicationHelper

  attr_reader :next_img, :prev_img, :current_index

  def initialize(artist, current_piece)
    @artist = artist
    @current_piece = current_piece
    thumbs # need this to init current index etc
  end

  def pieces
    @art_pieces ||= @artist.art_pieces.map { |ap| ArtPiecePresenter.new(ap) }
  end

  def num_pieces
    @num_pieces ||= pieces.count
  end

  def thumbs?
    thumbs.count.positive?
  end

  def row_class
    num_rows = (thumbs.length.to_f / 4.0).ceil.to_i
    "rows#{num_rows}"
  end

  def thumbs
    @thumbs ||= pieces.map.with_index do |item, idx|
      item_id = item.send(:id)
      item_path = item.path('thumb')
      style = background_image_style(item_path)
      thumb = {
        path: item_path,
        clz: 'tiny-thumb',
        id: item_id,
        link: url_helpers.art_piece_path(item),
        background_style: style
      }
      if item_id == @current_piece.id
        mark_as_current(idx)
        thumb[:clz] << ' selected'
      end
      OpenStruct.new(thumb)
    end
  end

  private

  def mark_as_current(idx)
    @current_index = idx
    nxt = (idx + 1) % num_pieces
    prv = (idx - 1) % num_pieces
    @next_img = pieces[nxt].id
    @prev_img = pieces[prv].id
  end
end

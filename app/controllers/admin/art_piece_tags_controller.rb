
module Admin

  class ArtPieceTagsController < BaseAdminController

    layout "mau-admin"

    def index
      @tags = tags_sorted_by_frequency
    end

    def cleanup
      @tags = tags_sorted_by_frequency
      @tags.each {|(tag, ct)| tag.destroy if ct <= 0 }
      redirect_to admin_art_piece_tags_url
    end

    def destroy
      @tag = ArtPieceTag.find(params[:id])
      @tag.destroy
      ArtPieceTag.flush_cache
      redirect_to(art_piece_tags_url)
    end

    private
    def tags_sorted_by_frequency
      all_tags = ArtPieceTag.all
      freq = ArtPieceTag.keyed_frequency
      all_tags.map do |tag|
        [tag, freq[tag.id].to_f]
      end.select(&:first).sort_by(&:last).reverse
    end

  end

end

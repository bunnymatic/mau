# frozen_string_literal: true

module Admin
  class ArtPieceTagsController < ::BaseAdminController
    def index
      @tags = ArtPieceTagService.tags_sorted_by_frequency.to_a + ArtPieceTagService.unused_tags
    end

    def cleanup
      ArtPieceTagService.delete_unused_tags
      redirect_to admin_art_piece_tags_url
    end

    def destroy
      load_tag
      ArtPieceTagService.destroy(@tag)
      redirect_to(admin_art_piece_tags_url)
    end

    private

    def load_tag
      @tag = ArtPieceTag.find(params[:id])
    end
  end
end

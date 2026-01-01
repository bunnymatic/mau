module Admin
  class ArtPiecesController < ::BaseAdminController
    before_action :admin_required, only: %i[edit update]
    before_action :set_art_piece, only: %i[edit update]

    def edit; end

    def update
      if @art_piece.update(art_piece_params)
        redirect_to edit_admin_art_piece_path(@art_piece)
      else
        render :edit, warning: 'There were problems updating the art piece'
      end
    end

    private

    def set_art_piece
      @art_piece = ArtPiece.find(params[:id])
    end

    def art_piece_params
      params.expect(art_piece: [:photo])
    end
  end
end

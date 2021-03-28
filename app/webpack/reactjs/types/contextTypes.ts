import { ArtPiece } from "@models.art_piece.model";

export interface ArtPiecesContext {
  artPiecesById: Record<number, ArtPiece>;
  currentArtPieceId: number;
}

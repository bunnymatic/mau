import { ArtPiece } from "@models/art_piece.model";
import * as types from "@reactjs/types";
import React, { createContext, FC } from "react";

export const ArtPiecesContext = createContext<types.ArtPiecesContext>({});
ArtPiecesContext.displayName = "ArtPiecesData";

interface ArtPiecesProviderProps {
  artPieces: ArtPiece[];
}

export const ArtPiecesProvider: FC<ArtPiecesProviderProps> = ({
  children,
  artPieces,
}) => {
  return (
    <ArtPiecesContext.Provider value={{ artPieces }}>
      {children}
    </ArtPiecesContext.Provider>
  );
};

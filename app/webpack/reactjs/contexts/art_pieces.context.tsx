import { ArtPiece } from "@models/art_piece.model";
import * as types from "@reactjs/types";
import React, { createContext, FC, useContext } from "react";

export const ArtPiecesContext = createContext<types.ArtPiecesContext>({
  artPieces: [],
});
ArtPiecesContext.displayName = "ArtPiecesData";

interface ArtPiecesProviderProps {
  artPieces: ArtPiece[];
}

export const ArtPiecesProvider: FC<
  ArtPiecesProviderProps & types.ChildrenProp
> = ({ children, artPieces }) => {
  return (
    <ArtPiecesContext.Provider value={{ artPieces }}>
      {children}
    </ArtPiecesContext.Provider>
  );
};

export const useArtPiecesContext = () => useContext(ArtPiecesContext);

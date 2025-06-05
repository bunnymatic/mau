import { ArtPiece } from "@models/art_piece.model";
import * as types from "@reactjs/types";
import React, {
  createContext,
  type PropsWithChildren,
  type ReactNode,
  useContext,
} from "react";

export const ArtPiecesContext = createContext<types.ArtPiecesContext>({
  artPieces: [],
});
ArtPiecesContext.displayName = "ArtPiecesData";

interface ArtPiecesProviderProps {
  artPieces: ArtPiece[];
}

export const ArtPiecesProvider = ({
  children,
  artPieces,
}: PropsWithChildren<ArtPiecesProviderProps>): ReactNode => {
  return (
    <ArtPiecesContext.Provider value={{ artPieces }}>
      {children}
    </ArtPiecesContext.Provider>
  );
};

export const useArtPiecesContext = () => useContext(ArtPiecesContext);

import { eachByIndex } from "@js/app/helpers";
import Flash from "@js/app/jquery/flash";
import { ArtPiece } from "@models/art_piece.model";
import { ArtCard } from "@reactjs/components/art_card";
import { Spinner } from "@reactjs/components/spinner";
import { jsonApi as api } from "@services/json_api";
import React, { FC, useEffect, useState } from "react";

interface ArtPageProps {
  artistId: number;
  initialArtPieceId?: number;
}

type ArtPiecesById = Record<number, ArtPiece>;

export const ArtPage: FC<ArtPageProps> = ({ artistId, initialArtPieceId }) => {
  const [artPieces, setArtPieces] = useState<ArtPiecesById>({});

  useEffect(() => {
    api.artPieces
      .index(artistId)
      .then((artPieces) => {
        setArtPieces(eachByIndex(artPieces));
      })
      .catch((_err) => {
        new Flash().show({
          error:
            "Ack!  We are having trouble finding that artist's art.  Try back later",
        });
      });
  }, [artistId, initialArtPieceId]);

  if (!artPieces) {
    return <Spinner />;
  }

  const cardClasses =
    "pure-u-1-1 pure-u-sm-1-1 pure-u-md-1-2 pure-u-lg-1-4 pure-u-xl-1-4";
  return Object.entries(artPieces).map(([id, artPiece]) => (
    <ArtCard key={id} artPiece={artPiece} classes={cardClasses} />
  ));
};

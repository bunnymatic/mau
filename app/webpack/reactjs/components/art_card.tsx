import { ArtPiece } from "@models/art_piece.model";
import { ArtModal } from "@reactjs/components/art_modal";
import { ArtPiecesContext } from "@reactjs/contexts/art_pieces.context";
import cx from "classnames";

import React, { FC, useEffect, useContext, useState } from "react";

interface AttributionProps {
  artPiece: ArtPiece;
}

const AttributionItems: FC<AttributionProps> = ({ artPiece }) => {
  if (!artPiece.dimensions && !artPiece.price) {
    return <div className="art-card__description-item">{artPiece.title}</div>;
  }
  return (
    <>
      <div className="art-card__description-item">
        {Boolean(artPiece.dimensions) && artPiece.dimensions}
      </div>
      <div className="art-card__description-item">
        {Boolean(artPiece.price) && (
          <span
            className={cx("art-card__price", {
              "art-card__price--sold": artPiece.hasSold,
            })}
          >
            {artPiece.displayPrice}
          </span>
        )}
      </div>
    </>
  );
};

interface ArtCardProps {
  artPiece: ArtPiece;
  classes?: string;
}

export const ArtCard: FC<ArtCardProps> = ({ artPiece, classes }) => {
  const [ image, setImage ] = useState<string|null>(null);

  useEffect(() => {
    artPiece.image('original').then(url => setImage(url))
  }, [artPiece?.id])
  return (
    <div className={cx("art-card", classes)}>
      <ArtModal artPiece={artPiece}>
        {image ? (
          <div
            className="image"
            style={{ backgroundImage: `url("${image}")` }}
          ></div>
        ) : (
          <div className="image image--empty" />
        )}
        {Boolean(artPiece.hasSold) && (
          <span className="art-card__sold">Sold</span>
        )}
        <div className="art-card__description">
          <AttributionItems artPiece={artPiece} />
        </div>
      </ArtModal>
    </div>
  );
};

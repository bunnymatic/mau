import { ArtPiece } from "@models/art_piece.model";
import { ArtModal } from "@reactjs/components/art_modal";
import cx from "classnames";
import React, { FC } from "react";

interface ArtCardProps {
  artPiece: ArtPiece;
  classes?: string;
}

export const ArtCard: FC<ArtCardProps> = ({ artPiece, classes }) => {
  return (
    <div className={cx("art-card", classes)}>
      <ArtModal artPiece={artPiece}>
        <div
          className="image"
          style={{ backgroundImage: `url("${artPiece.imageUrls.original}")` }}
        ></div>
        <div className="art-card__description">
          <div className="art-card__description-item">{artPiece.title}</div>
          <div className="art-card__description-item">
            {Boolean(artPiece.price) && (
              <span
                className={cx("art-card__price", {
                  "art-card__price--sold": artPiece.sold,
                })}
              >
                {artPiece.displayPrice}
              </span>
            )}
            {Boolean(artPiece.sold) && (
              <span className="art-card__sold">Sold</span>
            )}
          </div>
          {Boolean(artPiece.dimensions) && (
            <div className="art-card__description-item">
              {artPiece.dimensions}
            </div>
          )}
          {Boolean(artPiece.year) && (
            <div className="art-card__description-item">{artPiece.year}</div>
          )}
        </div>
      </ArtModal>
    </div>
  );
};

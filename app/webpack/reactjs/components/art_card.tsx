import { ArtModal } from "@reactjs/components/art_modal";
import * as types from "@reactjs/types";
import cx from "classnames";
import React, { FC } from "react";

interface ArtCardProps {
  id: number;
  title: string;
  sold?: boolean;
  price?: string;
  dimensions?: string;
  year?: string;
  classnames?: types.ClassNames;
  images: any;
}

export const ArtCard: FC<ArtCardProps> = ({
  classnames,
  id,
  title,
  sold,
  price,
  dimensions,
  year,
  images,
}) => {
  const classes = cx("art-card", classnames);
  return (
    <div className={classes}>
      <ArtModal id={id}>
        <div className="art-piece">
          <div
            className="image"
            style={{ backgroundImage: `url("${images.original}")` }}
          ></div>
          <div className="art-card__description">
            <div className="art-card__description-item">{title}</div>
            <div className="art-card__description-item">
              {Boolean(price) && (
                <span
                  className={cx("art-card__price", {
                    "art-card__price--sold": sold,
                  })}
                >
                  {price}
                </span>
              )}
              {Boolean(sold) && <span className="art-card__sold">Sold</span>}
            </div>
            {Boolean(dimensions) && (
              <div className="art-card__description-item">{dimensions}</div>
            )}
            {Boolean(year) && (
              <div className="art-card__description-item">{year}</div>
            )}
          </div>
        </div>
      </ArtModal>
    </div>
  );
};

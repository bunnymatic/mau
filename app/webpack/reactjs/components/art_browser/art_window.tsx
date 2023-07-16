import { backgroundImageStyle } from "@js/services";
import { ArtPiece } from "@models/art_piece.model";
import * as types from "@reactjs/types";
import cx from "classnames";
import React, { FC, useEffect, useState } from "react";

interface AnnotationProps {
  label: string;
  value?: string | number;
  classes?: types.ClassNames;
}

const Annotation: FC<AnnotationProps> = ({ label, value, classes }) => {
  if (!value) {
    return null;
  }
  return (
    <div className={cx("art-window__annotation", classes)}>
      {Boolean(label) && (
        <span className="art-window__annotation-label">{label}</span>
      )}
      <span className="art-window__annotation-value">{value}</span>
    </div>
  );
};

interface ArtWindowProps {
  art: ArtPiece;
}

export const ArtWindow: FC<ArtWindowProps> = ({ art }) => {
  const [image, setImage] = useState<string | null>(null);
  useEffect(() => {
    if (!art?.id) {
      return;
    }
    art
      .image("original")
      .then((url) => setImage(url))
      .catch(console.error);
  }, [art?.id]);

  if (!image) {
    return null;
  }
  return (
    <div className="art-window">
      <div className="art-window__image-container">
        <div
          className="art-window__image"
          style={backgroundImageStyle(image, {
            backgroundSize: "contain",
            backgroundRepeat: "no-repeat",
          })}
        >
          {Boolean(art.hasSold) && (
            <span className="art-window__sold">Sold</span>
          )}
        </div>
      </div>
      <div className="art-window__info-container">
        <div className="art-window__info--left">
          <Annotation
            label="Title:"
            value={art.title}
            classes="art-window__title"
          />
          <Annotation
            label="Price:"
            value={art.displayPrice}
            classes={cx("art-window__price", {
              "art-window__price--sold": art.hasSold,
            })}
          />
        </div>
        <div className="art-window__info--right">
          <Annotation
            label="Dimensions:"
            value={art.dimensions}
            classes="art-window__dimensions"
          />
          <Annotation
            label="Medium:"
            value={art?.medium?.name}
            classes="art-window__medium"
          />
          <Annotation
            label="Year:"
            value={art.year}
            classes="art-window__date"
          />
        </div>
      </div>
    </div>
  );
};

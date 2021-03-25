import Flash from "@js/app/jquery/flash";
import { backgroundImageStyle, jsonApi as api } from "@js/services";
import { ArtPiece } from "@models/art_piece.model";
import { CloseButton } from "@reactjs/components/close_button";
import { MauModal, setAppElement } from "@reactjs/components/mau_modal";
import { Spinner } from "@reactjs/components/spinner";
import { useModalState } from "@reactjs/hooks/useModalState";
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
    <div className={cx("art-modal__annotation", classes)}>
      {Boolean(label) && (
        <span className="art-modal__annotation-label">{label}</span>
      )}
      <span className="art-modal__annotation-value">{value}</span>
    </div>
  );
};

interface ArtModalWindowProps {
  id: number;
  artPieceIds: number[];
  handleClose: (MouseEvent) => void;
}

const findNextCyclic = (val, array) => {
  const current = array.indexOf(val)
  return array[(current + 1) % array.length];
}
const findPrevCyclic = (val, array) => {
  const current = array.indexOf(val)
  if (current === 0) {
    return array[array.length - 1];
  } else {
    return array[current - 1];
  }
}

const ArtModalWindow: FC<ArtModalWindowProps> = ({ id, artPieceIds, handleClose }) => {
  const [artPiece, setArtPiece] = useState<ArtPiece>();
  const [artPieceId, setArtPieceId] = useState<ArtPiece>(id);

  const handleNext = () => {
    const current = artPieceId;
    setArtPieceId(findNextCyclic(val, artPieceIds))
  }
  const handlePrevious = () => {
    const current = artPieceId;
    setArtPieceId(findPrevCyclic(val, artPieceIds))
  }

  useEffect(() => {
    api.artPieces
      .get(artPieceId)
      .then(setArtPiece)
      .catch((_error) => {
        new Flash().show({
          error: "We are having some issues getting that art.  Sorry!",
        });
      });
  }, [artPieceId]);

  setAppElement("body");

  return (
    <MauModal
      className="art-modal__content"
      isOpen={true}
      onRequestClose={handleClose}
    >
      {artPiece ? (
        <>
          <div className="art-modal__body">
            <div className="art-modal__close">
              <CloseButton handleClick={handleClose} />
            </div>
            <div className="art-modal__image-container">
              <div
                className="art-modal__image"
                style={backgroundImageStyle(artPiece.imageUrls.original, {
                  backgroundSize: "contain",
                  backgroundRepeat: "no-repeat",
                })}
              ></div>
            </div>
          </div>
          <div className="art-modal__footer">
            <div className="art-modal__footer--left">
              <Annotation
                label="Title:"
                value={artPiece.title}
                classes="art-modal__title"
              />
              <Annotation
                label="Dimensions:"
                value={artPiece.dimensions}
                classes="art-modal__dimensions"
              />
              <Annotation
                label="Date:"
                value={artPiece.date}
                classes="art-modal__date"
              />
            </div>
            <div className="art-modal__footer--right">
              <Annotation
                label="Medium:"
                value={artPiece?.medium?.name}
                classes="art-modal__medium"
              />
              <Annotation
                label="Price:"
                value={artPiece.displayPrice}
                classes={cx("art-modal__price", {
                  "art-modal__price--sold": artPiece.hasSold,
                })}
              />
            </div>
          </div>
        </>
      ) : (
        <Spinner />
      )}
    </MauModal>
  );
};

interface ArtModalProps {
  id: number;
  artPieceIds: number[];
}

export const ArtModal: FC<ArtModalProps> = ({ id, children, artPieceIds }) => {
  const { isOpen, open, close } = useModalState(false);
  return (
    <>
      {isOpen && <ArtModalWindow id={id} artPieceIds={artPieceIds} handleClose={close} />}
      <div
        onClick={(ev) => {
          ev.preventDefault();
          open();
        }}
      >
        {children}
      </div>
    </>
  );
};
